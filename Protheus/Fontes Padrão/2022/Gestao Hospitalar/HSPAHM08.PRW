#INCLUDE "hspahm08.ch"
#INCLUDE "PROTHEUS.CH" 
#include "TopConn.ch"
#INCLUDE "VKEY.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ HSPAHM08 ณ Autor ณ Bruno Santos          ณ Data ณ18/02/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Pedidos de Exames                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHM08(cAtendimento, cReserv, cCodLoc , nVisual, lItensLab) //nVisual (Indica se sera apenas para visualiza็ใo do pedido de exames 1 = sim)
 Local aSvKeys		:= GetKeys()                       
 Local bKeyF4		:=	SetKey(VK_F4, {|| FS_M08Leg() })
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPEnc := {}
 Local aButtons := {}     
 Local nOpcA,nLin  := 0
 Local nRadPes := 0, oRadPes
 Local oVisual, nPosicao := 0
 Local oCarater, nPosCarac := 0 
 Local aDespLab := {}
 
 Private cConfPed := .F.
 Private cCondGnj := ""                  
 Private lNovoPed := .F.
 Private lAlterou := .F.
 Private  lOcMsg := .F.
 Private cPaciente := ""
 Private lExDicLab	:= Hs_ExisDic({{"T", "GP9"}})
 Private lExDicLab2	:= Hs_ExisDic({{"C", "GBY_STALAB"}},.F.)

 Private aCpoGby := {"GBY_DATSOL","GBY_HORSOL","GBY_PROSOL","GBY_DESPRO","GBY_URGDES","GBY_COMPTO","GBY_CRMLAU","GBY_NOMLAU","GBY_CODLOC","GBY_NOMLOC","GBY_EXMEXT","GBY_VOLCOL","GBY_NUMAMO","GBY_CFGMMM","GBY_QUESTE","GBY_SEQDES","GBY_CODPCT","GBY_DESPCT","GBY_CODLAU","GBY_SOLICI"}
 Private aLeg := {{"GBY_STATUS == '0'", "BR_VERDE"},{"GBY_STATUS == '1'", "BR_AMARELO"},;
                  {"GBY_STATUS == '2'", "BR_AZUL"},{"GBY_STATUS == '3'", "BR_VERMELHO"},{"GBY_STATUS == '4'", "BR_CINZA"}}
                        
 Private oMemo, cTexto := ""        
 Private oMedSol, cMedSol := Space(TamSx3("GBY_CODCRM")[1]) //HS_IniPadr("SRA", 1, SubStr(PSWRET(1)[1,22], 5, TamSx3("RA_MAT")[1]), "RA_CODIGO",, .F.)
 Private oDescMed, cDesMed := ""//HS_IniPadr("SRA", 1, SubStr(PSWRET(1)[1,22], 5, TamSx3("RA_MAT")[1]), "RA_NOME",, .F.)
	
 Private aVldUsu := {}//{IIF(Empty(cMedSol),"",cMedSol),Substr(cUsuario, 7, 15)}

 Private oChkEfet, lChkEfet := .T.
 Private oChkUrg, lChkUrg := .F.

 Private oChkItem,   lChkItem := .T.
 Private oChkProPAD, lChkProPad := .F.

 Private aTela := {}, aGets := {}, aCDatAtu := {} 
 Private nRadEfe, nRadUrg , oRadEfe, oRadUrg
 Private nRadIte, nRadPro , oRadIte, oRadPro

 Private aHGBY := {}, aCGBY := {}, nUGBY := 0, oGDGBY , oGP8 
 Private aHGNJ := {}, aCGNJ := {}, nUGNJ := 0, oGDGNJ
 Private aHGA7 := {}, aCGA7 := {}, nUGA7 := 0, oGDGA7
 Private aHGA1 := {}, aCGA1 := {}, nUGA1 := 0, oGDGA1
  
 Private nGnjCodSeq := 0
 Private cGBJTipPro := "0/1/2"
 
 Private aCodUsr    := HS_VldDAnm(.F.)
    
 Private lMrkLaud   := .F., lMrkTiss   := .F., lMarca := .T.
 
 Private cCodPla 	:= ""
 Private cCodCon 	:= ""

 Private cTpNasc 	:= "", cCodLocGav := "", cNomeRn := "" //Variaveis Utilizadas para RN
 Private cEspUsu 	:= HS_REspMed(aCodUsr[2])
 
 Private __cFnBfPsq := "HS_M08BPsq()" 
 Private lNoChgGrid	:= lItensLab
 Private aMntPerg	:= {}
 Private nVisPrvt	:= nVisual
 
 Default cReserv 	:= ""
 Default cCodLoc 	:= ""    
 Default nVisual 	:= 0 
 Default lItensLab  := .F. //Variavel para listar no Grid as despesas vindas do atendimento referente ao Laboratorio


If !LockByName("ExecM24" + cAtendimento,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",cAtendimento,.T.)
	Return(Nil)
Else
	HSPGerFiCo("ExecM24",cAtendimento)
EndIf

If lItensLab //Verificar se hแ itens para solicita็ใo Laboratorio
	aDespLab := FS_DESPLAB(cAtendimento) 
	lItensLab := (Len(aDespLab) >= 1)
	If !lItensLab //Caso nao tenha e tenha sido chamado a partir da confirmacao do atendimento nใo abre a tela
		Return(Nil)
	EndIf
EndIf
 
 If !Hs_ExisDic({{"T", "GNJ"}}) .Or. !Hs_ExisDic({{"C", "GA7_PERSOL", "FNC 144067 - 30/04/08"}})  
  Return(nil)
 EndIf    
        
 If (Alias() # "GCY")
  DbSelectArea("GCY")
 EndIf
 
 If (IndexOrd() # 1)
  DbSetOrder(1)
 EndIf
 
 If (GCY->GCY_REGATE # cAtendimento)
  DbSeek(xFilial("GCY")+cAtendimento)
 EndIf       
 
 DbSelectArea("GCZ")
 DbSetOrder(2)
 DbSeek(xFilial("GCZ") + cAtendimento)
// cCodPla := HS_INIPADR("GD4",1, GCY->GCY_REGGER, "GD4_CODPLA",,.T.)
 cCodPla := GCZ->GCZ_CODPLA
 cCodCon := HS_INIPADR("GCM",2, cCodPla, "GCM_CODCON",,.T.)  
 
 If !Empty(aCodUsr[2]) .And. (Len(aCodUsr) < 3 .Or. aCodUsr[3])
  cMedSol := HS_IniPadr("SRA", 11, aCodUsr[2], "RA_CODIGO",, .F.)
	 cDesMed := HS_IniPadr("SRA", 11, aCodUsr[2], "RA_NOME",, .F.)
 EndIf
 
 aVldUsu := {IIF(Empty(cMedSol),"",cMedSol),cUserName}
 
  IF GAV->GAV_STATUS == "3" .And. Empty(GAV->GAV_REGATE)
 	HS_MsgInf(STR0048,STR0019,STR0013) //"Leito em higienizacao."###"Atencao" ### "Pedidos de Exames"
 	Return(Nil)
 ENDIF
 cPaciente := GCY->GCY_REGGER
 
 aSize 			:= MsAdvSize(.T.)
 
 aObjects := {}
 aAdd( aObjects, { 98, 000, .T., .T.} )
 aAdd( aObjects, { 98, 040, .T., .T.,.T.} )
 aAdd( aObjects, { 98, 050, .T., .T.} )
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPPanel := MsObjSize( aInfo, aObjects, .T. )
 
 aObjects := {}	
 aAdd( aObjects, { 060, 100, .T.,.T.} )
	aAdd( aObjects, { 040, 100, .T.,.T.,.T.} )
 
 aInfo  := { aPPanel[3, 2], aPPanel[3, 1], aPPanel[3, 4], aPPanel[3, 3], 0, 0 }
	aPInfo := MsObjSize( aInfo, aObjects, .T., .T.)

 aObjects := {}	
 aAdd( aObjects, { 100, 050, .T.,.T.,.T.} )
	aAdd( aObjects, { 100, 020, .T.,.T.,.T.} )
 aAdd( aObjects, { 100, 030, .T.,.T.,.T.} )
 
 aInfo := { aPInfo[2, 2], aPInfo[2, 1], aPInfo[2, 4], aPInfo[2, 3], 0, 0 }
	aPPed := MsObjSize( aInfo, aObjects, .T.)     
	
	aObjects := {}	
 aAdd( aObjects, { 100, 030, .T.,.T.,.T.} )
 aAdd( aObjects, { 100, 050, .T.,.T.,.T.} )
 aAdd( aObjects, { 100, 010, .T.,.T.,.T.} )
 aAdd( aObjects, { 100, 010, .T.,.T.,.T.} )
 
 aInfo := { aPInfo[1, 2], aPInfo[1, 1], aPInfo[1, 4], aPInfo[1, 3], 0, 0 }
	aPPro := MsObjSize( aInfo, aObjects, .T.)
	
	If !Empty(cTpNasc := cReserv) .AND. HS_SeekRet("GB2", "GCY->GCY_REGATE + cTpNasc", 1, .F., "cNomeRn", "GB2_NOME")                                      
 	cCodLocGav := cCodLoc
	Else
 	cTpNasc := ""
	EndIf      

	cCondGnj := "GNJ->GNJ_REGGER == '"+cPaciente+"' AND GNJ->GNJ_REGATE == '"+GCY->GCY_REGATE+"' "                       
 cCondGnj += " AND GNJ->GNJ_RESERV == '"+cTpNasc+"' "
  
 HS_BDados("GNJ", @aHGNJ, @aCGNJ, @nUGNJ, 1,, cCondGnj,,"GNJ_STATUS","GNJ_CODSEQ/GNJ_DATPED/GNJ_SOLCRM/GNJ_NOMSOL",,,,,,.T.,{{"GNJ_STATUS == '0'","BR_VERDE"},{"GNJ_STATUS == '1'","BR_CINZA"}})
 nGnjCodSeq := aScan(aHGNJ, {|aVet| aVet[2] == "GNJ_CODSEQ"})
 nGnjMedSol := aScan(aHGNJ, {|aVet| aVet[2] == "GNJ_SOLCRM"})     
 nGnjStatus := aScan(aHGNJ, {|aVet| aVet[2] == "GNJ_STATUS"})     
 nGnjDatPed := aScan(aHGNJ, {|aVet| aVet[2] == "GNJ_DATPED"})  
                                                                                                                                                                                                                                 
// HS_BDados("GBY", @aHGBY, @aCGBY, @nUGBY, 1,,IIF( Empty(aCGNJ[1,nGnjCodSeq]),"1 = 0","GBY->GBY_CODPED == '"+aCGNJ[1,nGnjCodSeq]+"'"),.T.,"GBY_STATUS","/",,,,{"GBY_IDLAUD","GBY_IDMARC"}, {"'LBNO'","Iif(GBY_EXMEXT == '0', 'LBNO', 'LBTIK')"},.T.,aLeg,,,,, aCpoGby) 
 HS_BDados("GBY", @aHGBY, @aCGBY, @nUGBY, 1,,"1 = 0",.T.,"GBY_STATUS","/",,,,{"GBY_IDLAUD","GBY_IDMARC"}, {"'LBNO'","Iif(GBY_EXMEXT == '0', 'LBNO', 'LBTIK')"},.T.,aLeg,,,,, aCpoGby) 
 
 nGbyStaReg := aScan(aHGBY, {|aVet| aVet[2] == "HSP_STAREG"})     
 nGBYIDMARC := aScan(aHGBY, {|aVet| aVet[2] == "GBY_IDMARC"})     
 aHGBY[nGBYIDMARC, 1] := "Docs/Relat" // // // //"Guia TISS"
 nGBYIDLAUD := aScan(aHGBY, {|aVet| aVet[2] == "GBY_IDLAUD"})     
 aHGBY[nGBYIDLAUD, 1] := STR0002            // // // //"Laudo"
 nGBYSTATUS := aScan(aHGBY, {|aVet| aVet[2] == "GBY_STATUS"})     
 aHGBY[nGBYSTATUS, 1] := STR0003  // // // //"Status"
 nGBYEXMEXT := aScan(aHGBY, {|aVet| aVet[2] == "GBY_EXMEXT"})
 nGBYSOLICI := aScan(aHGBY, {|aVet| aVet[2] == "GBY_SOLICI"})
 nGBYDATSOL := aScan(aHGBY, {|aVet| aVet[2] == "GBY_DATSOL"})
 nGBYHORSOL := aScan(aHGBY, {|aVet| aVet[2] == "GBY_HORSOL"})
 nGBYPROSOL := aScan(aHGBY, {|aVet| aVet[2] == "GBY_PROSOL"})
 nGBYDESPRO := aScan(aHGBY, {|aVet| aVet[2] == "GBY_DESPRO"})
 nGBYCRMLAU := aScan(aHGBY, {|aVet| aVet[2] == "GBY_CRMLAU"})
 nGBYNOMLAU := aScan(aHGBY, {|aVet| aVet[2] == "GBY_NOMLAU"})
 nGBYCODLOC := aScan(aHGBY, {|aVet| aVet[2] == "GBY_CODLOC"})
 nGBYNOMLOC := aScan(aHGBY, {|aVet| aVet[2] == "GBY_NOMLOC"})
 nGBYCODPCT := aScan(aHGBY, {|aVet| aVet[2] == "GBY_CODPCT"})
 nGBYDESPCT := aScan(aHGBY, {|aVet| aVet[2] == "GBY_DESPCT"})    
 nGBYSEQDES := aScan(aHGBY, {|aVet| aVet[2] == "GBY_SEQDES"})
 nGBYURGDES := aScan(aHGBY, {|aVet| aVet[2] == "GBY_URGDES"})
 nGBYCOMPTO := aScan(aHGBY, {|aVet| aVet[2] == "GBY_COMPTO"})
 nGBYCODLAU := aScan(aHGBY, {|aVet| aVet[2] == "GBY_CODLAU"}) 
 If lExDicLab
  	nGBYCFGMMM := aScan(aHGBY, {|aVet| aVet[2] == "GBY_CFGMMM"})
 	nGBYDESMMM := aScan(aHGBY, {|aVet| aVet[2] == "GBY_DESMAT"}) 
 	nGBYVOLCOL := aScan(aHGBY, {|aVet| aVet[2] == "GBY_VOLCOL"})
 	nGBYNUMAMO := aScan(aHGBY, {|aVet| aVet[2] == "GBY_NUMAMO"})
  	nGBYQUESTE := aScan(aHGBY, {|aVet| aVet[2] == "GBY_QUESTE"}) 	
 EndIf
 
 HS_BDados("GA7", @aHGA7, @aCGA7, @nUGA7, 2,, " GA7_PERSOL = '1' AND GA7_CODESP IN ('"+StrTran(cEspUsu,"/","','")+"') ",,,"GA7_CODPRO/GA7_DESC  ",,,,,, .T.)
 nGA7CODPRO := aScan(aHGA7, {|aVet| aVet[2] == "GA7_CODPRO"})
 nGA7DESC   := aScan(aHGA7, {|aVet| Trim(aVet[2]) == "GA7_DESC"})   

 HS_BDados("GA1", @aHGA1, @aCGA1, @nUGA1, 1,," 1 = 1 ",,,"GA1_CODPCT/GA1_DESC  /GA1_CODPRO/GA1_DESPRO",,,,,, .T.)
 nGA1CODPCT := aScan(aHGA1, {|aVet| aVet[2] == "GA1_CODPCT"})
 nGA1DESC   := aScan(aHGA1, {|aVet| Trim(aVet[2]) == "GA1_DESC"})      
 nGA1CODPRO := aScan(aHGA1, {|aVet| aVet[2] == "GA1_CODPRO"})
 nGA1DESPRO := aScan(aHGA1, {|aVet| aVet[2] == "GA1_DESPRO"})      

 nOpcA := 0
 DEFINE MSDIALOG oDlgM08 TITLE IIf(nVisual <> 1 ,STR0004,STR0004 + " - " + STR0049) From 000, 000 To aSize[6], aSize[5] Of oMainWnd Pixel   //aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel    // // // //"Pedido de Exames" "Visualiza็ใo"
             
  oPPesq	:=	tPanel():New(aPPanel[1, 1], aPPanel[1, 2],, oDlgM08,,,,,, aPPanel[1, 3], aPPanel[1, 4])
  oPPesq:Align := CONTROL_ALIGN_TOP
   
  @ 003, aPPanel[1, 4]-250 Say STR0005 Of oPPesq Pixel COLOR CLR_BLUE // // // //"M้d. Sol."
	 @ 002, aPPanel[1, 4]-225 MsGet oMedSol VAR cMedSol Size 35, 009 VALID FS_VldMed(cMedSol, @cDesMed) F3 "MED" Picture "@!" OF oPPesq Pixel COLOR CLR_BLACK When lNovoPed
	 @ 002, aPPanel[1, 4]-185 MsGet oDescMed VAR cDesMed Size 100, 009 OF oPPesq Pixel COLOR CLR_BLACK when .F.
 
  oBtnOk  := tButton():New(002, aPPanel[1, 4] - 65, STR0006, oPPesq, {|| IIf(nVisual <> 1, FS_GrvGnj(),HS_MSGINF(STR0050,STR0031,STR0004))}, 050, 015,,,, .T.) // // // //"Confirmar" "Pedido de Exames disponivel apenas para visualiza็ใo" "Aten็ใo" ""Pedido de Exames"
                
  @ aPPanel[2, 1], aPPanel[2, 2] FOLDER oFolder SIZE aPPanel[2, 3], aPPanel[2, 4] Pixel Of oDlgM08 Prompts STR0007 // // // //"Exames"

  oGDGBY  := MsNewGetDados():New(aPPanel[2, 1], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], GD_UPDATE+GD_DELETE,,,,{"GBY_URGDES", "GBY_COMPTO"},, 99999,,,, oFolder:aDialogs[1], aHGBY, aCGBY)
  oGDGBY:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT  
  oGDGBY:oBrowse:bDelete    := {|| FS_CANITEM(oGDGby:oBrowse:nAt) }
  oGDGBY:oBrowse:BlDblClick := {|| FS_EdGdGby(oGDGBY)}
  oGDGBY:oBrowse:bChange    := {|| Fs_RetPreu(oGDGBY:aCols[oGDGby:oBrowse:nAt, nGBYPROSOl])}
  oGDGBY:oBrowse:bGotFocus  := {|| Fs_RetPreu(oGDGBY:aCols[oGDGby:oBrowse:nAt, nGBYPROSOl])}   
  oGDGBY:cFieldOk           := "HS_GDAtrib(oGDGBY, {{nGbyStaReg, 'BR_AMARELO', 'BR_VERDE'}})" 
  
  oGDGby:lNewLine           := .F.
  oGDGby:OBROWSE:BHEADERCLICK := {|OBRW,NCOL, ADIM| Fs_ClickHd(OBRW,NCOL, ADIM)}
  HS_GDPesqu( , , oGDGBY, oPPesq, 002,.T.)   
  
  //Left    
  oPPrec	:=	tPanel():New(aPPro[1, 1], aPPro[1, 2],, oDlgM08,,,,,, aPPro[1, 3], aPPro[1, 4])
  @ aPPro[1, 1], aPPro[1, 2] FOLDER oFPrec SIZE aPPro[1, 3], aPPro[1, 4] Pixel Of oPPrec Prompts STR0008 // // // //"Preparo Exames"
	 oFPrec:Align := CONTROL_ALIGN_ALLCLIENT
	
		@ 0,0 GET oMemo  VAR cTexto MEMO READONLY SIZE aPPro[1, 3], aPPro[1, 4] OF oFPrec:aDialogs[1] PIXEL
  oMemo:Align := CONTROL_ALIGN_ALLCLIENT
 
  oPGDGA7	:=	tPanel():New(aPPro[2, 1], aPPro[2, 2],, oDlgM08,,,,,, aPPro[2, 3], aPPro[2, 4])  

  @ aPPro[2, 1], aPPro[2, 2] FOLDER oFolderExm SIZE aPPro[2, 3], aPPro[2, 4] Pixel Of oPGDGA7 Prompts STR0007, STR0009 // // //### //### //"Exames"###"Procedimentos Padrใo"
  oFolderExm:Align := CONTROL_ALIGN_ALLCLIENT      
  oFolderExm:bChange:= {|| IIF(oFolderExm:nOption == 1, HS_GDPesqu( , , oGDGA7, oPPesqGA7, 002,.T.,2,.T.," GA7_PERSOL = '1'"), HS_GDPesqu( , , oGDGA1, oPPesqGA7, 002,.T.,2,.T.) ) }
  
  oGDGA7 := MsNewGetDados():New(aPPro[2, 1], aPPro[2, 2], aPPro[2, 3], aPPro[2, 4],,,,,,,,,,, oFolderExm:aDialogs[1], aHGA7, aCGA7)
  oGDGA7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDGA7:oBrowse:BlDblClick := {|| FS_CAREXM(oGDGa7:aCols[oGDGa7:oBrowse:nAt, nGA7CODPRO])}
  oGDGA7:oBrowse:bChange := {|| Fs_RetPreu(oGDGA7:aCols[oGDGA7:oBrowse:nAt, nGA7CODPRO])}
  oGDGA7:oBrowse:bGotFocus := {|| Fs_RetPreu(oGDGA7:aCols[oGDGA7:oBrowse:nAt, nGA7CODPRO])}
  oGDGA7:Refresh()
  oGDGA1 := MsNewGetDados():New(aPPro[2, 1], aPPro[2, 2], aPPro[2, 3], aPPro[2, 4],,,,,,,,,,, oFolderExm:aDialogs[2], aHGA1, aCGA1)
  oGDGA1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDGA1:oBrowse:BlDblClick := {|| FS_CARPRPD()}
  oGDGA1:Refresh()
  oPCarater	:=	tPanel():New(aPPro[3, 1], aPPro[3, 2],, oDlgM08,,,,,, aPPro[3, 3], aPPro[3, 4])
  @ 000, 000 Say OemToAnsi(STR0010) Size 100, 010 OF oPCarater PIXEL COLOR CLR_BLUE // // // //"CARATER DA SOLICITACAO"
     
  oChkEfet := tCheckBox():New(000,150,OemToAnsi(STR0011), {|u|if( pcount()>0,lChkEfet:=u,lChkEfet)},oPCarater,050,010,,{||FS_DESMARCA("lChkEfet", "oChkUrg")},,,,,,.T.)  // // // //"Eletiva"
  oChkUrg := tCheckBox():New(000,200,OemToAnsi(STR0012), {|u|if( pcount()>0,lChkUrg:=u,lChkUrg)},oPCarater,050,010,,{||FS_DESMARCA("lChkUrg", "oChkEfet")},,,,,,.T.)  // // // //"Urgente"
  
  oPPesqGA7	:=	tPanel():New(aPPro[4, 1], aPPro[4, 2],, oDlgM08,,,,,, aPPro[4, 3], aPPro[4, 4]) 
  HS_GDPesqu( , , oGDGA7, oPPesqGA7, 002,.T.,2,.T.," GA7_PERSOL = '1'")  //Cabecalho de Procedimentos  => GA7_PERSOL=Permite Solicitacao      

  //Right
  @ aPInfo[2, 1], aPInfo[2, 2] FOLDER oFolder2 SIZE aPInfo[2, 3], aPInfo[2, 4] Pixel Of oDlgM08 Prompts STR0013 // // // //"Pedidos de Exames"
  
  //oPPesqPed	:=	tPanel():New(aPPed[1, 1], aPPed[1, 2],, oFolder2:aDialogs[1],,,,,/*CLR_GREEN*/, aPPed[1, 3], aPPed[1, 4]) //Quando a resolu็ใo do monitor ้ menor temos q tratar para que a tela abra normalmente
  oPPesqPed	:=	tPanel():New(aPPed[1, 1], aPPed[1, 2],, oFolder2:aDialogs[1],,,,,/*CLR_GREEN*/, aPPed[1, 3], Iif(aPPed[1, 4] < 38,aPPed[1, 4]+10,aPPed[1, 4]-23)) //Quando a resolu็ใo do monitor ้ menor temos q tratar para que a tela abra normalmente
  oPPesqPed:Align := CONTROL_ALIGN_TOP   

  oPGDPed	:=	tPanel():New(aPPed[2, 1], aPPed[2, 2],, oFolder2:aDialogs[1],,,,,/*CLR_BLUE*/, aPPed[2, 1], aPPed[2, 2])
  //oPGDPed	:=	tPanel():New(aPPed[2, 1], aPPed[2, 2],, oFolder2:aDialogs[1],,,,,/*CLR_BLUE*/, aPPed[2, 3], aPPed[2, 4])
  oPGDPed:Align := CONTROL_ALIGN_ALLCLIENT

  oPPedBtn	:=	tPanel():New(aPPed[3, 1], aPPed[3, 2],, oFolder2:aDialogs[1],,,,,, aPPed[3, 3], Iif(aPPed[3, 4] < 25,aPPed[3, 4]+15,aPPed[3, 4]))
  oPPedBtn:Align := CONTROL_ALIGN_BOTTOM
    
  nTamBtn  := IIF(aPInfo[2, 3]/5 < 0, -1,+1 )*aPInfo[2, 3]/5
  
  oBtnAlt  := tButton():New(002, 005        , STR0014        , oPPedBtn, {|| IIf(nVisual <> 1, Fs_NovoPed(),HS_MSGINF(STR0050,STR0031,STR0004))} , nTamBtn-10, 15,,,, .T.) // // // //"Novo" "Pedido de Exames disponivel apenas para visualiza็ใo","Aten็ใo","Valida็ใo Pedido de Exames"
  oBtnExc  := tButton():New(002, nTamBtn+5  , STR0015    , oPPedBtn, {|| IIf(nVisual <> 1, Fs_CanPed(),HS_MSGINF(STR0050,STR0031,STR0004))}  , nTamBtn-10, 15,,,, .T.) // // // //"Cancelar" "Pedido de Exames disponivel apenas para visualiza็ใo","Aten็ใo","Valida็ใo Pedido de Exames"
  oBtnImp  := tButton():New(002, 2*nTamBtn+5, STR0002       , oPPedBtn, {|| IIf(nVisual <> 1, Fs_ImpLaud(),HS_MSGINF(STR0050,STR0031,STR0004))} , nTamBtn-10, 15,,,, .T.) // // // //"Laudo" "Pedido de Exames disponivel apenas para visualiza็ใo","Aten็ใo","Valida็ใo Pedido de Exames"
  //oBtnTiss := tButton():New(002, 3*nTamBtn+5, STR0016    , oPPedBtn, {|| FS_ImpExm()}  , nTamBtn-10, 15,,,, .T.) // // // //"Guia Solic."
  oBtnSair := tButton():New(002, 4*nTamBtn+5, STR0017        , oPPedBtn, {|| oDlgM08:End()}, nTamBtn-10, 15,,,, .T.) // // // //"Sair"
          
  oPPedTest	:=	tPanel():New(002,3*nTamBtn+5,, oPPedBtn,,,,,CLR_HGRAY, nTamBtn-10, 15)
  
  oBtn := TBtnBmp2():New( 0 , 0, nTamBtn+35 , 30,'S4WB010N' ,'S4WB010N' , , , , oPPedTest , , , .T.)
  oBtn:SetPopupmenu(Fs_MenuPop())        
  oBtn:cCaption := "Docs/Relat"
  oBtn:Align := CONTROL_ALIGN_ALLCLIENT
  oBtn:Refresh()
          
  oGDGNJ := MsNewGetDados():New(aPPed[2, 1], aPPed[2, 2], aPPed[2, 3], aPPed[2, 4],2,,,,,,,,,, oPGDPed, aHGNJ, aCGNJ)
  oGDGNJ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDGNJ:bChange         := {|| IIf(lNovoPed,FS_HSPGRVG(),FS_MntExm())}                                                                                                                                                        
//  oGDGNJ:oBrowse:bGotFocus  :=  {|| IIf(lNovoPed,FS_HSPGRVG(),FS_MntExm())}   	  
                      
  HS_GDPesqu( , , oGDGNJ, oPPesqPed, 002)   
//AADD(aExames,{TMPLAB->GD7_CODDES,TMPLAB->GD7_SEQDES, cGczCodCRM})
  If lItensLab
  	Fs_NovoPed(aDespLab[1,3]) 
  	lOcMsg := .T.
  	For nLin := 1 To Len(aDespLab)
  		FS_CAREXM(aDespLab[nLin,1],,aDespLab[nLin,2])
  	Next nLin
  EndIf
  
 ACTIVATE MSDIALOG oDlgM08     
 
UnLockByName("ExecM24" + cAtendimento,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",cAtendimento)

 RestKeys( aSvKeys , .T. )                                                                            
Return()          
Static Function FS_HSPGRVG()

If !lOcMsg .And. lNovoPed == .F. 
	If MsgYesNo(STR0051) 
		lNovoPed := .F.
		FS_MntExm()
	EndIf  
Else
	lOcMsg := .F.
EndIf

Return ()

Static Function FS_DESMARCA(lVar, oObj)
  Default lVar := .F.
     
  &("l"+Substr(oObj,2)) := !&(lVar)  
  &(oObj+":Refresh()")          
Return(nil)                  

Static Function FS_VldMed(cMedSol, cDesMed) 
 Local lRet := .T.
 Local aArea := GetArea()

 //If EMPTY(cMedSol)
  //HS_MsgInf("M้dico Obrigat๓rio", "Aten็ใo", "Valida็ใo M้dico")
 //Endif
 If !EMPTY(cMedSol)
  DbSelectArea("SRA")
  DbSetOrder(11)
  If !(DbSeek(xFilial("SRA") + cMedSol))
  	HS_MsgInf(STR0018, STR0019, STR0020) //###### //###### //###### //"M้dico nใo encontrado"###"Aten็ใo"###"Valida็ใo M้dico"
  	lRet := .F.                       
  Else
   cDesMed := SRA->RA_NOME
  Endif
 EndIf
 
 RestArea(aArea)
 Return(lRet)
 
Static Function Fs_GrvGBY(cProSol, cCodPed, lInclui)
Local aArea 	:= getArea()
Local lAchou 	:= .F.
Local cPedHis	:= ""

DbSelectArea("GBY")
DbSetOrder(1)

If !lInclui
	lAchou := DbSeek(xFilial("GBY")+oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySolici])
EndIf

If oGDGby:aCols[oGDGby:oBrowse:nAt, Len(oGDGby:aHeader)+1]
	If DbSeek(xFilial("GBY")+oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySolici])
		RecLock("GBY", .F.)
		DbDelete()
		MsUnLock()
	Endif
Else
	RecLock("GBY",!lAchou)
	
	If !lAchou
		M->GBY_SOLICI := HS_VSxeNum("GBY", "M->GBY_SOLICI", 1)
	Else
		M->GBY_SOLICI := oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySolici]
	EndIf
	
	GBY->GBY_FILIAL := xFilial("GBY")
	GBY->GBY_SOLICI := M->GBY_SOLICI
	If !Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySeqDes])
		GBY->GBY_SEQDES := oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySeqDes]
	EndIf
	If lExDicLab
		GBY->GBY_NUMAMO := oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyNUMAMO]
		GBY->GBY_VOLCOL := oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyVOLCOL]
		GBY->GBY_CFGMMM := 	oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCFGMMM]
		GBY->GBY_QUESTE := 	oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYQUESTE]
	EndIf
	GBY->GBY_DATSOL := IIF(!lAchou,oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYDATSOL],GBY_DATSOL)
	GBY->GBY_HORSOL := IIF(!lAchou,oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYHORSOL],GBY_HORSOL)
	GBY->GBY_REGGER := IIF(!lAchou,GCY->GCY_REGGER,GBY_REGGER)
	
	
	GBY->GBY_NOMPAC := IIF(!lAchou,IIF(Empty(cTpNasc),GCY->GCY_NOME,cNomeRn),GBY_NOMPAC)
	
	GBY->GBY_REGATE := IIF(!lAchou,GCY->GCY_REGATE,GBY_REGATE)
	GBY->GBY_PROSOL := IIF(!lAchou,oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYPROSOL],GBY_PROSOL)
	
	cAliasOld := Alias()
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("GBY_DESPRO") .And. SX3->X3_CONTEXT == "R" // Contexto Real
		GBY->GBY_DESPRO := HS_IniPadr("GA7", 1, GBY->GBY_PROSOL, "GA7_DESC",, .F.)
	EndIf
	DbSelectArea(cAliasOld)
	
	GBY->GBY_CODCRM := IIF(!lAchou,cMedSol,GBY_CODCRM)
	GBY->GBY_USUSOL := IIF(!lAchou,cUserName,GBY_USUSOL)
	
	GBY->GBY_CODLOC := IIF(!lAchou,oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODLOC],GBY_CODLOC)
	GBY->GBY_LOCSOL := IIF(!lAchou,IIF(Empty(cTpNasc),GCY->GCY_CODLOC,cCodLocGav),GBY_LOCSOL)
	
	GBY->GBY_PROLAU := IIF(!lAchou,cProSol,GBY_PROLAU)
	
	GBY->GBY_STATUS := IIF(!lAchou,AllTrim(str(aScan(aLeg,{|aVet| oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYSTATUS]  == aVet[2]})-1)),GBY_STATUS)
	If lExDicLab2
		GBY->GBY_STALAB := IIF(!lAchou,"0",GBY_STALAB)
	Endif
	GBY->GBY_CODPED := IIF(!lAchou,cCodPed,GBY_CODPED)
	If Empty(cPedHis)
		cPedHis := IIF(!lAchou,cCodPed,GBY_CODPED)
	EndIf
	
	GBY->GBY_EXMEXT := IIF(!lAchou,oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYEXMEXT],GBY_EXMEXT)
	
	GBY->GBY_RECLAU := IIF(!lAchou,"1",GBY->GBY_RECLAU)
	
	GBY->GBY_URGDES := oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYURGDES]
	GBY->GBY_COMPTO := oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCOMPTO]
	GBY->GBY_RESERV := cTpNasc
	
	MsUnLock()
EndIf
If lExDicLab 
	If !Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYQUESTE])
		DbSelectArea("GPI")
		DbSetOrder(1)
		If !DbSeek(xFilial("GPI") + M->GBY_SOLICI)
			FS_HisResp(cPedHis,"GPI", "GPI->GPI_CDEXAM", "GPI", oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYQUESTE])
			aMntPerg := HS_MntPerg(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYQUESTE], Nil,"Questionแrio - " + oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYDESPRO], , .F., "GPI", "oGP8",, Nil, CONTROL_ALIGN_ALLCLIENT, .T., "G",,.T.,.T.)
			If aMntPerg[1] == 1			
				HS_GrvResp("GPI", {{"GPI->GPI_CDEXAM", M->GBY_SOLICI}, {"GPI->GPI_CDQUES", oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYQUESTE]}} , aMntperg[2])
			EndIf
		EndIf
	EndIf
EndIf
  
RestArea(aArea) 
Return(nil)
 
 Static Function FS_GrvGnj()
  Local aArea := getArea()
  Local nI := 0
  Local cCodSeq := ""
  Local aCPR    := {}
  Local cInfAdc := ""
  
  If (!lNovoPed .AND. !lAlterou) 
   Return(nil)  
  EndIf
  
  If EMPTY(cMedSol)
   HS_MsgInf(STR0021, STR0019, STR0020)   // //### //###### //###### //"M้dico Obrigat๓rio"###"Aten็ใo"###"Valida็ใo M้dico"
   Return(nil)
  ElseIf !(HS_IniPadr("GBJ", 1, cMedSol, "GBJ_TIPPRO",, .F.) $ "0/1/2")
   HS_MsgInf(STR0022, STR0019, STR0020)   // //### //###### //###### //"Profissional escolhido nใo pode fazer solicita็๕es de exames"###"Aten็ใo"###"Valida็ใo M้dico"
   Return(nil)  
  EndIf 
  
  If !Fs_VldUsu()
   Hs_MsgInf(STR0023,STR0019,STR0024) //### // //###### //###### //"Usuแrio sem permissใo para alterar/incluir itens no pedido"###"Aten็ใo"###"Valida็ใo Usuแrio"
   lNovoPed := .F.
   lAlterou := .F.
   Return(nil)
  ElseIf lAlterou .And. oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGNJSTATUS] # "BR_VERDE"  
   Hs_MsgInf(STR0025,STR0019,STR0026) //### // //###### //###### //"Pedido nใo pode ser alterado"###"Aten็ใo"###"Valida็ใo Pedido"
   Return(nil)  
  EndIf
  
  If !lNovoPed
   cCodSeq :=  oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGnjCodSeq]
  EndIF                                                     
  
  lNovoPed := .F.
  lAlterou := .F.
  cConfPed := .T.
  Begin Transaction   

  DbSelectArea("GNJ")
  DbSetOrder(1)   
  
  If !(Empty(cCodSeq))
   DbSeek(xFilial("GNJ")+cCodSeq)
  EndIf                          
  
  RecLock("GNJ", Empty(cCodSeq))
   GNJ_FILIAL := xFilial("GNJ")
   GNJ_CODSEQ := IIF(Empty(cCodSeq),GETSXENUM('GNJ','GNJ_CODSEQ',,1),cCodSeq)
   GNJ_DATPED := IIF(Empty(cCodSeq),dDataBase,GNJ_DATPED)
   GNJ_STATUS := IIF(Empty(cCodSeq),"0",GNJ_STATUS)
   GNJ_LOGINC := IIF(Empty(cCodSeq),cUserName,GNJ_LOGINC)
   GNJ_SOLCRM := IIF(Empty(cCodSeq),cMedSol,GNJ_SOLCRM)
   GNJ_REGATE := GCY->GCY_REGATE
   GNJ_REGGER := GCY->GCY_REGGER
   GNJ_RESERV := cTpNasc
  MsUnLock() 
           
  For nI := 1 To Len(oGDGby:aCols)   
   If oGDGby:aCols[nI, nGbyStareg] # "BR_VERDE"
   oGDGby:oBrowse:nAt := nI
   Fs_GrvGBY(oGDGby:aCols[nI, nGbyProSol], GNJ_CODSEQ, Empty(cCodSeq))
    aAdd(aCPR, aClone(oGDGby:aCols[nI]))
   EndIf
  Next nI
  
		cInfAdc := STR0027+ GNJ_CODSEQ  +chr(13)+chr(10)+; //"N๚mero Pedido: "
		           STR0005 +": "+GNJ_SOLCRM+" - "+cDesMed // //"M้d. Sol."

		If !Empty(cTpNasc)
 		cInfAdc += chr(13)+chr(10)+STR0028+cNomeRn		 //"Para "
		EndIf 	 
		
  ConfirmSx8() 
  End Transaction  
  
  If !Fs_GDspPr(GNJ->GNJ_CODSEQ)    
   While __lSX8 
    RollBackSXE()
   End
   Return(.F.)                  
  EndIf  
  
		If len(aCPR) > 0
   Hs_MsgM24(GCY->GCY_REGATE, {{1, aCPR}}, "", "", {{2, "GBY", "GBY", nGBYPROSOL, nGBYDATSOL, nGBYDESPRO, "1"}}, cCodPla, STR0029,cInfAdc) //"Solicita็ใo de Exames"
  EndIf
  
  HS_MsgInf(STR0030, STR0031, STR0004) //### // //###"Atenใo"### //###### //"Pedido de exames salvo com sucesso"###"Ate็ใo"###"Pedido de Exames"
  
  FS_MntExm(.T.,Empty(cCodSeq))
  RestArea(aArea)
 Return(nil)                
 
Static Function Fs_CarExm(cProc, cProcPadr,cSeqDes)
Local cTpLocEx, cCdParLab	:= "" 
Local cSql					:= ""
Local lUrgLab				:= .T.

Default cProcPadr := ""
  
If !Fs_VldUsu()
	Hs_MsgInf(STR0023,STR0019,STR0024) //###### //###### //###### //"Usuแrio sem permissใo para alterar/incluir itens no pedido"###"Aten็ใo"###"Valida็ใo Usuแrio"
	Return(nil)
ElseIf !lNovoPed .And. oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGNJSTATUS] # "BR_VERDE"
	Hs_MsgInf(STR0025,STR0019,STR0026) //###### //###### //###### //"Pedido nใo pode ser alterado"###"Aten็ใo"###"Valida็ใo Pedido"
	Return(nil)
EndIf

If Hs_DespAut("GBY", cCodPla, cProc, dDataBase, "1")
	If !MsgYesNo(STR0032+cProc+"] "+AllTrim(Hs_IniPadr("GA7",1, cProc, "GA7_DESC",,.F.))+STR0033+chr(13)+chr(10)+; //"Exame ["###" nใo ้ coberto pelo conv๊nio do paciente."
		STR0034)  //"Deseja realmente solicitแ-lo?"
		Return(nil)
	EndIf
EndIf

If !lNovoPed
	lAlterou := .T.
EndIf

If !Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYPROSOL])
	oGDGby:AddLine(.T.,.F.)
	oGDGby:lNewLine := .F.
EndIf

oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYDATSOL] := dDataBase
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYHORSOL] := Time()
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYPROSOL] := cProc
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYDESPRO] := Posicione('GA7', 1, xFilial('GA7') + cProc, 'GA7_DESC')//oGDGa7:aCols[oGDGa7:oBrowse:nAt, nGA7DESC]
If !Empty(cSeqDes)
	oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYSeqDes] := cSeqDes
EndIf

oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODLOC] := HS_IsLaudo(IIF(Empty(cTpNasc),GCY->GCY_CODLOC, cCodLocGav), cProc, .T.)[3] // Setor de Laudos
cTpLocEx := Posicione("GCS",1,xFilial("GCS")+oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODLOC],"GCS_TIPLOC")
If cTpLocEx == "G" .AND. lExDicLab //Parametrizacao Laboratorio
	 DbSelectArea("GP9")
	 DbSetOrder(2) //CODPRO + CODLOC
	 If DbSeek(xFilial("GP9") + cProc + oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODLOC])
		cCdParLab := GP9->GP9_CODPAR
		oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYVOLCOL] := GP9->GP9_VOLCOL
		oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYNUMAMO] := GP9->GP9_NUMAMO                                
		oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYQUESTE] := GP9->GP9_QSTATE
		
		cSql := " SELECT GPG_CODSEQ,GPG_CODMAT FROM " + RetSqlname("GPG") + " WHERE GPG_CODPAR = '" + cCdParLab + "' "
		cSql += " AND GPG_IDPADR = '1' AND D_E_L_E_T_ <> '*' AND GPG_FILIAL = '" + xFilial("GPG") + "' "
		
 		TCQUERY cSql NEW ALIAS "TMPGPG"
 				
		If !TMPGPG->(Eof())
			oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCFGMMM] := TMPGPG->GPG_CODSEQ		
			//oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYDESMMM] := Posicione("GPC",1,xFilial("GPC")+TMPGPG->GPG_CODMAT,"GPC_DESCRI")
		EndIf
		TMPGPG->(DbCloseArea())
		lUrgLab := !(GP9->GP9_URGENC == "0")
	EndIf
EndIf
			
		
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYNOMLOC] := Posicione("GCS",1,xFilial("GCS")+oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODLOC],"GCS_NOMLOC")
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYSTATUS] := "BR_VERDE"
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYSTAREG] := "BR_VERMELHO"
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYEXMEXT] := IIF(Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODLOC]) .And. Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYSeqDes]),"1","0")
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYIDMARC] :=  IIF(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYEXMEXT] == "1","LBTIK","LBNO")
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYIDLAUD] :=  "LBNO"
oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYURGDES] :=  IIF(lChkUrg .AND. lUrgLab,"1","0")

If !Empty(cProcPadr)
	oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYCODPCT] :=  cProcPadr
	oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYDESPCT] :=  oGDGa1:aCols[oGDGa1:oBrowse:nAt, nGa1DESC]
EndIf

oGDGby:Refresh() 
 	
Return(nil)                                                                                       

Static Function Fs_CarPrPd()
  
  Local aItePct := HS_RetPct(oGDGa1:aCols[oGDGa1:oBrowse:nAt, nGA1CODPRO], 3)
  Local nForPct := 0
  
  aSort(aItePct,,, {| X, Y | X[7] > Y[7]}) // Ordena para colocar o item principal na primeira linha do aItePct
  
  For nForPct := 1 To Len(aItePct)
   If aItePct[nForPct, 1] == "1" // Materiais e Medicamentos
    Fs_CarExm(PadR(AllTrim(aItePct[nForPct, 2]), TamSx3("GBY_PROSOL")[1] ),oGDGa1:aCols[oGDGa1:oBrowse:nAt, nGA1CODPCT])   
   EndIf
  Next nForPct
Return(nil)    


Static Function FS_MntExm(lRefresh, lNewPed)
Default lRefresh := .F.
Default lNewPed  := .F.
 
If lNoChgGrid
	lNoChgGrid := .F.
 	Return(Nil)
EndIf

If Len(oGDGBY:aCols) > 0
	if lNovoPed  
		If MsgYesNo(STR0035, STR0019)  // // //### //### //"O novo registro nใo foi salvo. Deseja Salvแ-lo?"###"Aten็ใo"
			Fs_GrvGnj()
		EndIf
	ElseIf lAlterou
		If MsgYesNo(STR0036, STR0019)  // // //### //### //"Hแ altera็๕es que nใo foram salvas. Deseja Salvแ-las?"###"Aten็ใo"
			Fs_GrvGnj()
		EndIf 
	EndIf 
EndIf

lNovoPed := .F.
lAlterou := .F.
lMrkTiss := .F.
   
If lRefresh
	aCGNJ := {}            
	aHGNJ := {}
	nUGNJ := 0
	nOldnAt := oGDGNJ:oBrowse:nAt
	HS_BDados("GNJ", @aHGNJ, @aCGNJ, @nUGNJ, 1,, cCondGnj,,"GNJ_STATUS","GNJ_CODSEQ/GNJ_DATPED/GNJ_SOLCRM/GNJ_NOMSOL",,,,,,.T.,{{"GNJ_STATUS == '0'","BR_VERDE"},{"GNJ_STATUS == '1'","BR_CINZA"}})
	oGDGNJ:SetArray(aCGNJ)
	oGDGNJ:Refresh()      
	oGDGNJ:oBrowse:nAt := IIF(lNewPed, len(aCGNJ), nOldnAt)
EndIf 
 
If !lNovoPed
	cMedSol := 	IIF(Empty(oGDGNJ:aCols[oGDGNJ:oBrowse:nAt,nGnjMedSol]),;
				IIF(!Empty(aCodUsr[2]) .And. (Len(aCodUsr) < 3 .Or. aCodUsr[3]),;
				HS_IniPadr("SRA", 11, aCodUsr[2], "RA_CODIGO",, .F.),;//HS_IniPadr("SRA", 1, substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1]) , "RA_CODIGO",, .F.),;
				Space(TamSx3("GBY_CODCRM")[1])),;	                       
				oGDGNJ:aCols[oGDGNJ:oBrowse:nAt,nGnjMedSol])
	oMedSol:Refresh()
	cDesMed := HS_IniPadr("SRA", 11,cMedSol, "RA_NOME",, .F.)
	oDescMed:Refresh()
EndIf
	 
aHGBY := {}
aCGBY := {}
nUGBY := 0 

HS_BDados("GBY", @aHGBY, @aCGBY, @nUGBY, 1,,IIF( Empty(oGDGNJ:aCols[oGDGNJ:oBrowse:nAt,nGnjCodSeq]),"1 = 0","GBY->GBY_CODPED == '"+oGDGNJ:aCols[oGDGNJ:oBrowse:nAt,nGnjCodSeq]+"'"),.T.,"GBY_STATUS","/",,,,{"GBY_IDLAUD","GBY_IDMARC"}, {"'LBNO'","Iif(GBY_EXMEXT == '0', 'LBNO', 'LBTIK')"},.T.,aLeg,,,,, aCpoGby)  
oGDGBY:SetArray(aCGBY)
oGDGBY:Refresh()

Return(nil) 

Static Function Fs_RetPreu(cProced)
 Local aArea := getArea()
 Local cPrec := ""
 
 DbSelectArea("GNJ")
 
 cSql := " Select GCK.R_E_C_N_O_ REG" +;
   						"			From "+RetSqlName("GA7")+" GA7 " +;
									"   Join "+RetSqlName("GCJ")+" GCJ " +;
									"     on GCJ.GCJ_GRPPRE = GA7.GA7_GRPPRE AND GCJ.GCJ_FILIAL = '"+xFilial("GCJ")+"' AND GCJ.D_E_L_E_T_ <> '*' "+;
									"   Join "+RetSqlName("GCI")+" GCI " +;
									"     on GCI.GCI_GRPPRE = GCJ.GCJ_GRPPRE AND GCI.GCI_FILIAL = '"+xFilial("GCI")+"' AND GCI.D_E_L_E_T_ <> '*' "+;
									"   Join "+RetSqlName("GCK")+" GCK " +;
									"     on GCK.GCK_CODPRE = GCI.GCI_CODPRE AND GCK.GCK_TIPPRE = '0' " +;
       	 "				AND GCK.GCK_FILIAL = '"+xFilial("GCK")+"' AND GCK.D_E_L_E_T_ <> '*' "+;
									"  Where GA7.GA7_CODPRO = '"+cProced+"' "+;
									"    AND GA7.GA7_FILIAL = '"+xFilial("GA7")+"' AND GA7.D_E_L_E_T_ <> '*' "

	cSql := ChangeQuery(cSql)	

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
	DbGoTop()		
 	
 While !Eof()   	
 	DbSelectArea("GCK")
 	DbGoTo(QRY->REG)								
	 cPrec += 	GCK->GCK_PRECAU+chr(10)+chr(13)   
	 
	 DbSelectArea("QRY")
	 DbSkip()
	End
	 
 DbSelectArea("QRY")
	DbCloseArea()
	 
	cTexto := cPrec
	
	oMemo:Refresh()
	
	RestArea(aArea)								
Return(nil)                 

Static Function FS_EdGdGby(oNewGetD)
Local lRet 		:= .T.
Local cCodPar	:= ""   
Local cCodSeq	:= ""   
Local cCodMat	:= ""   
Local aRetMMM	:= {}

If(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2] $ "GBY_IDMARC" ;
	.And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt,Len(oNewGetD:aHeader)+1]) ;
	.And.  oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSTATUS] # "BR_CINZA"
	oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyIdMarc] :=  IIF(oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyIdMarc] == "LBNO","LBTIK","LBNO")
ElseIf(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2] $ "GBY_IDLAUD" ;
	.And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt,Len(oNewGetD:aHeader)+1]) ;
	.And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSTATUS] $ "BR_VERDE/BR_CINZA"
	oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyIdLaud] :=  IIF(oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyIdLaud] == "LBNO","LBTIK","LBNO")
ElseIf(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2] $ "GBY_URGDES/GBY_COMPTO"      ;
	.And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt,Len(oNewGetD:aHeader)+1]) ;
	.And. oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSTATUS] $ "BR_VERDE"
	oNewGetD:EDITCELL( oNewGetD:OBROWSE, oNewGetD:oBrowse:nAt, oNewGetD:oBrowse:nColPos )
	If !lNovoPed
		lAlterou := .T.
	EndIf
ElseIf(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2] $ "GBY_CFGMMM" ;
	.And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt,Len(oNewGetD:aHeader)+1]) ;
	.And.  oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSTATUS] # "BR_CINZA" ;
	.And.  !Empty(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYCODLOC])
	If !Empty(oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyCFGMMM])
		DbSelectArea("GPG")
		DbSetOrder(6)
		If DbSeek(xFilial("GPG") + 	oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyCFGMMM])
			cCodPar := GPG->GPG_CODPAR
			If HS_CountTB("GPG", "GPG_CODPAR = '" + cCodPar + "'")  > 1
				aRetMMM := FS_CFGMMM(oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyCFGMMM],cCodPar)
				cCodSeq := aRetMMM[1]
				cCodMat := aRetMMM[2]
				If cCodSeq <> oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyCFGMMM] 
					oNewGetD:aCols[oNewGetD:oBrowse:nAt,nGbyCFGMMM] := cCodSeq
//					oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYDESMMM] := Posicione("GPC",1,xFilial("GPC")+cCodMat,"GPC_DESCRI")
					lAlterou := .T.					
				EndIf 
			EndIf
		EndIf
	Else
		HS_MSGINF("Nใo hแ configura็ใo de Meio de Coleta / Metodo / Mat. Biologico para este procedimento neste setor!",STR0019,STR0013) //"Nใo hแ configura็ใo de Meio de Coleta / Metodo / Mat. Biologico para este procedimento neste setor"###"Atencao" ### "Pedidos de Exames"
	EndIf
ElseIf(oNewGetD:aHeader[oNewGetD:oBrowse:nColPos, 2] $ "GBY_QUESTE" ;
	.And. !oNewGetD:aCols[oNewGetD:oBrowse:nAt,Len(oNewGetD:aHeader)+1]) ;
	.And.  oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSTATUS] # "BR_CINZA" ;
	.And.  !Empty(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYCODLOC]) ;
	.And.  !Empty(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI]) ;
	.And.  !Empty(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE]) 	
	
	DbSelectArea("GPI")
	DbSetOrder(1)
	If DbSeek(xFilial("GPI") + oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI])
  		HS_BusResp("GPI", {{"GPI->GPI_CDEXAM", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI]}}, "GPI")  		
		aMntPerg := HS_MntPerg(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE], Nil,"Questionแrio - " + oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYDESPRO], , nVisPrvt == 1, "GPI", "oGP8",, Nil, CONTROL_ALIGN_ALLCLIENT, .T., "G",,,.T.)  		
    	If aMntPerg[1] == 1 .AND. nVisPrvt <> 1
    		HS_GrvResp("GPI", {{"GPI->GPI_CDEXAM", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI]}, {"GPI->GPI_CDQUES", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE]}} , aMntperg[2])
    	EndIf 
    	//HSPRQUES("GPI", "GPI_CDEXAM", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI],oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE])		
	Else
		FS_HisResp(oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGnjCodSeq],"GPI", "GPI->GPI_CDEXAM", "GPI", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE])
		aMntPerg := HS_MntPerg(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE], Nil,"Questionแrio - " + oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYDESPRO], , .F., "GPI", "oGP8",, Nil, CONTROL_ALIGN_ALLCLIENT, .T., "G",,.T.,.T.)
    	If aMntPerg[1] == 1
    		HS_GrvResp("GPI", {{"GPI->GPI_CDEXAM", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI]}, {"GPI->GPI_CDQUES", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE]}} , aMntperg[2])
    	EndIf
		//	HSPRQUES("GPI", "GPI_CDEXAM", "000000",oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYQUESTE]) // Imprime vazio
		//HS_GrvResp(cAlias, aChave, aCposGrv)
	EndIf
	 	
EndIF 

	
 oNewGetD:oBrowse:Refresh()

Return(lRet)

Static Function Fs_CanItem(nPos, lCancPed)
 Local aArea := getArea()        
 Default lCancPed := .F.

 If !lNovoPed
  lAlterou := .T.
 EndIf
   
 oGDGby:oBrowse:nAt := nPos 
  
 If !oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStatus] $ "BR_VERDE/BR_CINZA/BR_PRETO"
  Hs_MsgInf(STR0037,STR0019,STR0038) //### //### //### //"Opera็ใo nใo permitida para Exames com Laudo Gerado"###"Aten็ใo"###"Valida็ใo Cancelamento"
  RestArea(aArea)
  Return(.F.)                                                    
 ElseIf oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStatus] == "BR_VERDE" .And. !Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYSEQDES])
  Hs_MsgInf("Opera็ใo nใo permitida, pois solicita็ใo de exame possuํ despesa gerada.",STR0019,STR0038) //### //### //### //"Opera็ใo nใo permitida para Exames com Laudo Gerado"###"Aten็ใo"###"Valida็ใo Cancelamento"
  RestArea(aArea)
  Return(.F.)                                                    
 EndIf       
 
 If !Empty(oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySolici])
  DbSelectArea("GBY")
  DbSetOrder(1)
  If DbSeek(xFilial("GBY")+oGDGby:aCols[oGDGby:oBrowse:nAt, nGbySolici])
   If (lCancPed .And. GBY->GBY_STATUS == "4") .Or. (GBY->GBY_STATUS == "4" .And. oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGnjStatus] == "BR_CINZA")
    RestArea(aArea)
    Return(.T.)                                                       
   End
   RecLock("GBY", .F.)
    GBY->GBY_STATUS := IIF(GBY->GBY_STATUS == "4","0","4")    
    GBY->GBY_LOGCAN := IIF(GBY->GBY_STATUS == "4","",Hs_LogArq())    
   MsUnLock()    
   
   oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStatus]  := aLeg[Val(GBY->GBY_STATUS)+1, 2]     
   HS_GDAtrib(oGDGBY, {{nGbyStaReg, "BR_AMARELO", "BR_VERDE"}})
  EndIf   
 Else
  oGDGby:DelLine() 
  IF oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStatus] == "BR_PRETO"
   oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStatus]  := "BR_VERDE"
   oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStareg]  := "BR_AMARELO"  
  Else
   oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStatus]  := "BR_PRETO"  
   oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyStareg]  := "BR_PRETO"  
  EndIf 
 EndIF
 oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYIDMARC] :=  IIF(oGDGby:aCols[oGDGby:oBrowse:nAt, nGBYEXMEXT] == "1","LBTIK","LBNO")
 oGDGby:aCols[oGDGby:oBrowse:nAt, nGbyIDLaud]  := "LBNO"                 
 oGDGBY:Refresh()
 RestArea(aArea)
Return(.T.)              

Static Function Fs_CanPed()
  Local aArea := getArea()
  Local nI := 0
  Local lOk := .T.
                
  If !Fs_VldUsu()
   Hs_MsgInf(STR0023,STR0019,STR0024) //###### //###### //###### //"Usuแrio sem permissใo para alterar/incluir itens no pedido"###"Aten็ใo"###"Valida็ใo Usuแrio"
   lNovoPed := .F.
   lAlterou := .F.
   Return(nil)
  EndIf
  
  DbSelectArea("GNJ")
  DbSetOrder(1)
  If DbSeek(xFilial("GNJ")+oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGNJCodSeq])
   
   If GNJ->GNJ_STATUS == "1"
    Hs_MsgInf(STR0039,STR0019,STR0038) // //### //###### //###### //"Pedido de Exame jแ cancelado"###"Aten็ใo"###"Valida็ใo Cancelamento"
    RestArea(aArea)
    Return(nil)
   EndIF 
   Begin Transaction           
    For nI := 1 to Len(oGDGBY:aCols)
     If !Fs_CanItem(nI, .T.)
      Hs_MsgInf(STR0040,STR0019,STR0038) // //### //###### //###### //"Pedido de Exame nใo pode ser cancelado"###"Aten็ใo"###"Valida็ใo Cancelamento"
      RestArea(aArea)
      DisarmTransaction()
	  lOk := .F.
      Exit
     EndIF
    Next nI    
    If lOk
    	RecLock("GNJ")
     	GNJ_STATUS := "1"
     	GNJ_LOGCAN := Hs_LogArq()
    	MsUnLock()  
    
    	oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGNJStatus] := "BR_CINZA"
    	oGDGNJ:Refresh()
	EndIf
   End Transaction 
  EndIf
  restArea(aArea)
return(nil)

Static Function Fs_NovoPed(cMedGCZ)
Default cMedGCZ := "" //Medico do campo GCZ_CODCRM

 lNovoPed := .T. 
 
 aHGBY := {}
 aCGBY := {}
 nUGBY := 0
 HS_BDados("GBY", @aHGBY, @aCGBY, @nUGBY, 1,," 1 = 0",.T.,"GBY_STATUS","/",,,,{"GBY_IDLAUD","GBY_IDMARC"}, {"'LBNO'","Iif(GBY_EXMEXT == '0', 'LBNO', 'LBTIK')"},.T.,aLeg,,,,, aCpoGby)  
 oGDGBY:SetArray(aCGBY)
 oGDGBY:Refresh()
 
If Empty(cMedGCZ) 
	cMedSol := IIF(!Empty(aCodUsr[2]) .And. (Len(aCodUsr) < 3 .Or. aCodUsr[3]),;
				HS_IniPadr("SRA", 11, aCodUsr[2], "RA_CODIGO",, .F.),;//HS_IniPadr("SRA", 1, substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1]) , "RA_CODIGO",, .F.),;
				Space(TamSx3("GBY_CODCRM")[1]))
Else
	cMedSol := cMedGCZ
EndIf
	 oMedSol:Refresh()
	 cDesMed := HS_IniPadr("SRA", 11,cMedSol, "RA_NOME",, .F.)
	 oDescMed:Refresh()
 
 
Return(Nil)


Static Function Fs_ImpLaud()
 Local aArea := getArea()
 Local nI := 0
 
 Private __aMarkBrw := {}
 
 For nI := 0 to len(oGDGBY:aCols)
  If oGDGBY:aCols[oGDGBY:oBrowse:nAt, nGBYIDLAUD] == "LBTIK"
   aAdd(__aMarkBrw,{oGDGBY:aCols[oGDGBY:oBrowse:nAt, nGBYSOLICI], ;
                    oGDGBY:aCols[oGDGBY:oBrowse:nAt, nGBYCODLAU], ;
                    oGDGBY:aCols[oGDGBY:oBrowse:nAt, nGBYSTATUS] == "BR_VERDE"})
  EndIf
 Next nI
 
 HS_M17IMPR()
 RestArea(aArea)
Return(nil)

Static Function Fs_VldUsu()
 Local lRet := .T.
 
 If !lNovoPed
  lRet := (cMedSol == aVldUsu[1] .Or. GNJ->GNJ_LOGINC == aVldUsu[2])
 EndIf
Return(lRet)                                                              

Static Function FS_ImpExm()
Local aArea 		:= getArea()
Local aRValPr 		:= {}
Local aCPR 			:= {}
Local nI 			:= 0                  
Local lImpGuia		:= .F.
Private cLogoGH		:= ""       					
Private aSM0Dados	:= {}
Private lVsTISS		:= IIF(GetMV("MV_VISTISS") == "S", .F., .T.)  // S para visualizar e N para nใo visualizar// F visualiza a impressใo T imprimi direto
Private nLayout		:= 2    //1 - Formato Ofํcio II (216x330mm)
Private cNrSeqG		:= HS_IniPadr("GCZ", 2,GCY->GCY_REGATE, "GCZ_NRSEQG")	 
Private aCptoM08	:= {} 																										//2 - Formato A4 (210x297mm)
Private lImpExam    := SuperGetmv("MV_IMPEXAM",,.T. )
		 																									//3 - Formato Carta (216x279mm)
Pergunte("HSPTIS",GetMV("MV_DEFPAPE",, "N") == "S")
nLayout := MV_PAR01
 
aAdd(aSM0Dados, {SM0->M0_CGC, SM0->M0_NOMECOM, SM0->M0_ENDENT, SM0->M0_COMPENT, SM0->M0_CIDENT, SM0->M0_ESTENT, SM0->M0_CEPENT, GETMV("MV_HSPCNES") })

//21/08/2013 - FNC TGLZMC
//Valida็ใo de CRM antes da entrada no menu de impre็ใo.

If Empty(cMedSol) .or. FS_VldMed(cMedSol, @cDesMed) == .F.
  HS_MsgInf("M้dico Obrigat๓rio", "Aten็ใo", "Valida็ใo M้dico")

Else  					
	For nI := 1 to Len(oGDGBY:aCols)                                                  
		If oGDGBY:aCols[nI,nGBYIDMARC] == "LBTIK" .And. oGDGBY:aCols[nI,nGBYSTATUS] # "BR_CINZA"  .and. (lImpExam  .or. oGDGby:aCols[nI,1] # "BR_VERMELHO")         	
			lImpGuia := .T.
			aRValPr := HS_RValPr(oGDGBY:aCols[nI,nGBYPROSOL], cCodPla, IIF(Empty(cTpNasc),GCY->GCY_CODLOC, cCodLocGav), Time(), "2", GCY->GCY_CODCRM,, {GCY->GCY_ATENDI, GCY->GCY_ATENDI, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE},.F., DDATABASE) 	
				aAdd(aCPR, {"","",oGDGBY:aCols[nI,nGBYDATSOL],oGDGBY:aCols[nI,nGBYHORSOL],"",aRValPR[2,15],aRValPR[2,18],1,0,"","","",oGDGBY:aCols[nI,nGBYPROSOL],"1","0",""})   
			
			If !Empty(oGDGBY:aCols[nI,nGBYCOMPTO])
				aAdd(aCptoM08, {oGDGBY:aCols[nI,nGBYPROSOL],oGDGBY:aCols[nI,nGBYCOMPTO]})
			Else 
				aAdd(aCptoM08, {"",""})		
			EndIf
		EndIf
	Next nI                                                                                   
Endif	 
If lImpGuia 

  //  cNrSeqG        Variavel para posicionar no registro do atendimento, e trazer o numero de sequencia de despesa.
	Hs_ImpSadt(cNrSeqG, GCY->GCY_REGATE, oGDGNJ:aCols[oGDGNJ:oBrowse:nAt,nGNJDATPED],, cPaciente, cCodPla, oGDGNJ:aCols[oGDGNJ:oBrowse:nAt, nGnjMedSol],,,,,aCPR,,, aSM0Dados, "M08")

EndIf
	
restArea(aArea)
Return(nil) 

Function Hs_VlPdEx(cRegAte, lExbMsg, cTpNasc)
 Local lRet := .T.
 Local aArea := getArea()
 Local cCond := " GBY.GBY_REGATE = '" + cRegAte + "' AND GBY.GBY_SEQDES = '" + SPACE(LEN(GBY->GBY_SEQDES)) + "' AND GBY.GBY_STATUS = '1' "
 
 Default cTpNasc := ""
 
 cCond += " AND GBY.GBY_RESERV = '"+IIF(Empty(cTpNasc),SPACE(LEN(GBY->GBY_RESERV)),cTpNasc)+"' "
 
 lRet := HS_CountTb("GBY", cCond) == 0
 
 If !lRet .And. lExbMsg
  lRet := MsgYesNo(STR0041)  // // // //"Hแ exames laudados que nใo foram liberados. Deseja prosseguir com a opera็ใo?"
 EndIf
 
  RestArea(aArea)
  Return(lRet)

Static Function FS_M08Leg()
 BrwLegenda(STR0004,STR0042, {	{"BR_VERDE"   ,	STR0043},;	  //"Nao Gerados"  //"Pedido de Exames"###"Legenda"###"Nao Gerados"
											 																																{"BR_AMARELO" ,	STR0044},;	  //"Gerados" //"Gerados"
											 																																{"BR_AZUL"    ,	STR0045},;	 //"Liberados" //"Liberados"
											 																																{"BR_VERMELHO",	STR0046},;  //"Entregue" //"Entregue"
											 																																{"BR_CINZA"   ,STR0047}})  // // // //"Cancelado"
Return(.T.)

Static Function Fs_ClickHd(OBRW,NCOL,ADIM)
 
 If oGDGby:LCANEDITLINE
  OBRW:NCOLPOS := NCOL
  GETCELLRECT(OBRW,@ADIM)
  If !(oGDGby:aHeader[NCOL, 2] $ "GBY_IDMARC/GBY_IDLAUD")                     
   GETDEDITMENU(oGDGby,ADIM) 
  ElseIf lMarca        
   Fs_MrkAll() 
   lMarca := .F.
   Return(Nil)
 EndIf
 EndIf  
 lMarca := .T.
  
Return(Nil)  
 
Static Function Fs_MrkAll()
 Local nI := 0
 Local cTik := ""
 
 cTik := IIF(IIF(oGDGby:aHeader[oGDGby:oBrowse:ColPos, 2] == "GBY_IDMARC", Eval({||lMrkTiss := !lMrkTiss, !lMrkTiss}), Eval({|| lMrkLaud := !lMrkLaud, !lMrkLaud}) ),"LBNO","LBTIK")
 
 For nI := 1 to len(oGDGby:aCols)                                   
  If (oGDGby:aHeader[oGDGby:oBrowse:ColPos, 2] == "GBY_IDLAUD" .And. oGDGby:aCols[nI, nGbyStatus] == "BR_VERDE") .Or. oGDGby:aCols[nI, Len(oGDGby:aHeader)+1] .Or. oGDGby:aCols[nI, nGbyStatus] $ "BR_CINZA" 
   Loop
  End 
  oGDGby:aCols[nI, oGDGby:oBrowse:ColPos] := cTik  
 Next 

 oGdGby:Refresh() 
Return(.T.)

Static Function Fs_GDspPr(cCodSeq)
 Local aArea     := GetArea()
 Local nX        := 0
 //Local cMsgGuia  := ""
	Local cMsgGNova := "Deseja lan็ar nova guia no Atendimento?"
	Local cMsgNGcz  := "Nใo foi encontrado guia em aberto no Atendimento. Deseja lan็ar nova guia com a despesa ?"
 Local bFnGerGui := {|| }
 Local cSql      := ""
 Local cNrSeqG   := ""
 Local cMsg      := ""
 Local lRet      := .T.
 Local aAux      := {}
 Local aMBrw  := {}   
                                  
 Private cCondGcu  := ""    
 
 aHGBY := {}
 aCGBY := {}
 nUGBY := 0 
 HS_BDados("GBY", @aHGBY, @aCGBY, @nUGBY, 1,,"GBY->GBY_CODPED == '"+cCodSeq+"'",.T.,"GBY_STATUS","/",,,,{"GBY_IDLAUD","GBY_IDMARC"}, {"'LBNO'","Iif(GBY_EXMEXT == '0', 'LBNO', 'LBTIK')"},.T.,aLeg,,,,, aCpoGby)  
 
 For nX := 1 to Len(aCGBY)       
  If Empty(aCGBY[nX, nGBYCODLOC]) .And. Empty(aCGBY[nX, nGBYSEQDES])
   If HS_IsLaudo(IIF(Empty(cTpNasc),GCY->GCY_CODLOC, cCodLocGav), aCGBY[nX, nGBYPROSOL])[4]
    aAdd(aMBrw, {aCGBY[nX, nGbyStatus], aCGBY[nX, nGBYPROSOL], aCGBY[nX, nGBYDESPRO], aCGBY[nX, nGBYSOLICI], aCGBY[nX, nGBYCODLAU]})
   EndIf
  EndIf
 Next             

 aMBrw := aClone(Fs_MntDesp(aMBrw))
 If Len(aMBrw) == 0   
  RestArea(aArea)
  Return(.T.)   
  EndIf
 
 cSql := " SELECT GCU.GCU_CODTPG "
 cSql += "   FROM "+RetSqlName("GCU")+" GCU "     
 cSql += "   JOIN "+RetSqlName("GCV")+" GCV ON GCV.GCV_FILIAL = '"+xFilial("GCV")+"' AND GCV.D_E_L_E_T_ <> '*' "
 cSql += "    AND GCV.GCV_CODTPG = GCU.GCU_CODTPG AND GCV.GCV_CODPLA = '"+cCodPla+"' "      
 cSql += "  WHERE GCU.GCU_FILIAL = '"+xFilial("GCU")+"' AND GCU.D_E_L_E_T_ <> '*' "
 cSql += "    AND GCU.GCU_TPGUIA IN ("+IIf(GCY->GCY_ATENDI == "0", "'0','6'", IIf(GCY->GCY_ATENDI == "1","'0','1','2','3','5'", IIf(GCY->GCY_ATENDI == "2","'0','4','5'","'0','1','2','3','4','5'")))+")"

 TcQuery cSql NEW ALIAS "TMPGCU"
 
 DbSelectArea("TMPGCU")  
 
 DbGoTop()

 While !TMPGCU->(EoF())     
  cCondGcu += IIF(Empty(cCondGcu),"",",")+"'"+TMPGCU->GCU_CODTPG+"'"
  DbSkip()
 End
       
 DbSelectArea("TMPGCU")  
 DbCloseArea()
  
 cCondGCU  := " GCU_CODTPG IN ("+cCondGcu+")"
  
 bFnGerGui := {|| Fs_GerGuia(cRegAte, cRegGer, "0", cAtendi, dDataAte, cLocAte, cCodPla,, cCondGCU)} //HSPAHM17
 
 Begin Transaction   
  Hs_GerDesp(aMBrw, GCY->GCY_REGATE, cPaciente, GCY->GCY_ATENDI, GCY->GCY_DATATE, IIF(FunName() == "HSPAHM30", GAV->GAV_CODLOC, GCY->GCY_LOCATE), cCodPla,,, cMsgGNova, cMsgNGcz, "", bFnGerGui)
 End Transaction              
 
 RestArea(aArea)
Return(lRet)               

Static Function Fs_MntDesp(aCPr)
 Local aRet    := {}          
 Local aCols   := {}
 Local aHeader := {}
 Local nOpca   := 0
 Local nX      := 0
 Local lMarca := .T. 
 Local oDlg         
 Local ABUTTONS := {}
   
 aAdd(aButtons, {"CHECKED", {|| FS_MarcT(lMarca, oGDPR), lMarca := !lMarca}, "Todos", "Marcar Todos"}) 
  
 If Len(aCPr) == 0   
  Return(aRet)   
 EndIf      
 
 For nX := 1 to Len(aCPr)
  aAdd(aCols,{"LBTIK", aCPr[nX, 1],aCPr[nX, 2],aCPr[nX, 3],aCPr[nX, 4],aCPr[nX, 5], .F.}) 
 Next 

 Aadd(aHeader, {" ", "cMark", "@BMP"  , 2, 0, ".F.", ""    , "C", "", "V" , "" , "","","V"}) 
 aAdd(aHeader, aClone(aHGBY[nGbyStatus]))
 aAdd(aHeader, aClone(aHGBY[nGBYPROSOL]))
 aAdd(aHeader, aClone(aHGBY[nGBYDESPRO]))
 aAdd(aHeader, aClone(aHGBY[nGBYSOLICI]))
 aAdd(aHeader, aClone(aHGBY[nGBYCODLAU]))     
 
 DEFINE MSDIALOG oDlg TITLE "Lan็amento Exames na Conta Paciente" From 000, 000 To 300, 700 Of oMainWnd Pixel   
 
  oGDPR := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHeader, aCols)
  oGDPR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
  oGDPR:oBrowse:BlDblClick := { || FS_DbClik(oGDPR) }

 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||nOpca := 1, IIF(!FS_VldMarc(oGDPR, 1), nOpca := 0, oDlg:End())}, {|| nOpca := 0, oDlg:End()},, aButtons)
 
 If nOpcA == 0 
  Return(aRet)  
 EndIf 
 
 For nX := 1 to Len(aCols)
  If aCols[nX, 1] == "LBTIK"                                         
   aAdd(aRet,{aCols[nX, 5],aCols[nX, 6],aCols[nX, 1] == "BR_VERDE"}) 
  EndIf
 Next 
 
Return(aRet) 

Static Function FS_DbClik(oObj)
 If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "LBTIK/LBNO"
  oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := IIF(oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] == "LBTIK", "LBNO", "LBTIK")
 EndIf 
Return(Nil)       
 
Static Function FS_VldMarc(oObj, nPos)
 
 Local lRet := .T.
 
 If !(lRet := (aScan(oObj:aCols, {| aVet | aVet[nPos] == "LBTIK"}) > 0))
  HS_MsgInf("Nenhum exame selecionado.", "Aten็ใo", "Valida็ใo Exame") //"Nใo hแ guias selecionadas."###"Aten็ใo"###"Valida็ใo da guia TISS"
 EndIf
 
Return(lRet)

Static Function FS_MarcT(lMarca, oObj, aPos)

 Local nForCols := 0
 Local nContFor := 0
 Local cMarcT   := IIF(lMarca, "LBTIK", "LBNO")
                                 
 Default aPos := {1}
           
 For nForCols := 1 To Len(oObj:aCols)
  For nContFor := 1 To Len(aPos)
   oObj:aCols[nForCols, aPos[nContFor]] := cMarcT 
  Next
 Next

Return(Nil)

Function HS_M08BPsq()
 //__aFnBfPsq[1] -- Chave
 //__aFnBfPsq[2] -- Objeto
 //__aFnBfPsq[3] -- @Filtro 
 If Substr(__aFnBfPsq[2]:aHeader[1,2],1,at("_",__aFnBfPsq[2]:aHeader[1,2])-1) == "GA7" .And. Empty(__aFnBfPsq[1])
  cFiltro := " GA7_PERSOL = '1' AND GA7_CODESP IN ('"+StrTran(cEspUsu,"/","','")+"') "
 EndIf
 
Return(.T.)
 
Static Function Fs_MenuPop()
Local oMenu

 MENU oMenu POPUP
  MENUITEM "Guia Tiss"     ACTION  Fs_ImpExm()
  MENUITEM "Ordem Servi็o" ACTION Fs_ImpOs(.F.)
  MENUITEM "Protocolo" ACTION Fs_ImpOs(.T.)  
 ENDMENU
 
Return oMenu

Static Function Fs_ImpOs(lProt)
 Local aArea := getArea()
 Local nX    := 0
 Local aCPr  := {}
 
//Validar se o pedido selecionado estแ com o Status de Aprovado.
cConfPed := Iif(oGDGby:aCols[1][2] == "BR_VERDE",.T.,.F.)
 
 //21/08/2013 - FNC TGLZMC
//Valida็ใo de CRM antes da entrada no menu de impre็ใo.
 
 If ((Empty(cMedSol) .or. FS_VldMed(cMedSol, @cDesMed) == .F.)) 
  HS_MsgInf("M้dico Obrigat๓rio", "Aten็ใo", "Valida็ใo M้dico")

 Elseif cConfPed == .F.
  HS_MsgInf("Obrigat๓rio Confirmar","Aten็ใo","Favor realizar a confirma็ใo do pedido")
 
 Else 
     For nX := 1 to Len(oGDGby:aCols)
  
     If oGDGby:aCols[nX, nGBYIDMARC] == "LBTIK"
     aAdd(aCPr, oGDGby:aCols[nX, nGBYSOLICI])
    EndIf
 
 Next 

 HSPAHR91(GCY->GCY_REGATE, oGDGnj:aCols[oGDGnj:nAt, nGnjCodSeq], , aCPr, lProt)
Endif
 RestArea(aArea)
Return(nil)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DESPLABบ Autor ณ Rogerio Tabosa     บ Data ณ  25/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se hแ novos exames para realizacao                บฑฑ
ฑฑบ          ณ no setor de laboratorio                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DESPLAB(cAte)
Local aArea 		:= getArea()
Local aExames 		:= {}
Local cSql 			:= ""
Local cNrseqG		:= "" 
Local cGczCodCRM	:= ""
Local cCodGPP		:= ""
Local lGrpLab		:= .F.

cSql := " SELECT MAX(GCZ_NRSEQG) NRSEQG, GCZ_CODCRM FROM " + RetSqlName("GCZ") + " WHERE GCZ_REGATE = '" + cAte + "'" 
cSql += " AND D_E_L_E_T_ <> '*' AND GCZ_FILIAL = '" + xFilial("GCZ") + "' GROUP BY GCZ_CODCRM "

TcQuery cSql NEW ALIAS "TMPLAB"

If !TMPLAB->(Eof())
	cNrseqG := TMPLAB->NRSEQG
	cGczCodCRM := TMPLAB->GCZ_CODCRM
Else
	TMPLAB->(DbCloseArea())
	Return({})
EndIf
TMPLAB->(DbCloseArea())

cSql := " SELECT GD7_CODDES, GD7_SEQDES , GA7_CODGPP FROM " + RetSqlName("GD7") + " GD7 " 
cSql += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7_CODPRO = GD7_CODDES
cSql += " AND GA7.D_E_L_E_T_ <> '*' AND GA7_FILIAL = '" + xFilial("GA7") + "'
cSql += " WHERE GD7_NRSEQG = '" + cNrseqG + "' AND GD7_SLAUDO = '1' "
cSQl += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("GBY") + " GBY WHERE GBY_SEQDES = GD7_SEQDES "
cSql += " AND GBY.D_E_L_E_T_ <> '*' AND GBY_FILIAL = '" + xFilial("GBY") + "') "
cSql += " AND GD7.D_E_L_E_T_ <> '*' AND GD7_FILIAL = '" + xFilial("GD7") + "' 
cSql += " ORDER BY GA7_CODGPP " 

TcQuery cSql NEW ALIAS "TMPLAB"

TMPLAB->(DbGoTop())
If !TMPLAB->(Eof())   
	While !TMPLAB->(Eof())
		If cCodGpp <> TMPLAB->GA7_CODGPP
			lGrpLab := FS_VGRPLAB(TMPLAB->GA7_CODGPP)
		EndIf 
		If lGrpLab
			AADD(aExames,{TMPLAB->GD7_CODDES,TMPLAB->GD7_SEQDES, cGczCodCRM})
		Endif
		cCodGpp := TMPLAB->GA7_CODGPP
		TMPLAB->(DbSkip())
	End
EndIf
TMPLAB->(DbCloseArea())

RestArea(aArea)
Return(aExames)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VGRPLABบ Autor ณ Rogerio Tabosa     บ Data ณ  25/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se o grupo do procedimento tem executante do      บฑฑ
ฑฑบ          ณ setor tipo G-Laboratorio                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_VGRPLAB(cGruPro) 
Local cSql := ""  
Local lRet	:= .F.

If Empty(cGruPro)
	Return(.F.)
EndIf

cSql := " SELECT GAQ_CODLOC CODLOC "
cSql += "   FROM "+RetSqlName("GAQ")+" GAQ "
cSql += "   JOIN "+RetSqlName("GCS")+" GCS ON GCS_FILIAL = '"+xFilial("GCS")+"' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GAQ_CODLOC  AND GCS_TIPLOC='G'"
cSql += "  WHERE GAQ_FILIAL = '"+xFilial("GAQ")+"' AND GAQ.D_E_L_E_T_ <> '*' AND GAQ_GRUPRO = '"+cGruPro+"' "           
cSql += "  UNION  "
cSql += " SELECT GNQ_CODLOC CODLOC "
cSql += "   FROM "+RetSqlName("GNQ")+" GNQ "
cSql += "   JOIN "+RetSqlName("GCS")+" GCS ON GCS_FILIAL = '"+xFilial("GCS")+"' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GNQ_CODLOC AND GCS_TIPLOC='G' "
cSql += "  WHERE GNQ_FILIAL = '"+xFilial("GNQ")+"' AND GNQ.D_E_L_E_T_ <> '*' AND GNQ_GRUPRO = '"+cGruPro+"' "

TCQUERY cSql NEW ALIAS "QRYGRP"  

lRet := !QRYGRP->(Eof())    

QRYGRP->(DbCloseArea())

Return(lRet)

Static Function FS_CFGMMM(cCodSeq, cCodPar)

Local aArea := getArea()
Local cSql  := ""
Local cTitulo  := ""
Local cCodigo	:= ""
Local aHeadMMM := {}, aColsMMM := {}, nUGPG := 0, nCFGMMM := 0
Local nOpca := 0, nX := 0
Local aRet  := {"",""} // [1]Codigo Sequencial [2] Codigo Material
Local aCpoMMM  := {"GPG_CODSEQ","GPG_CODMCO","GPG_DESMCO","GPG_CODMET","GPG_DESMET","GPG_CODMAT","GPG_DESMAT"}
Local oGDMMM 

Private Inclui := .F. 

HS_BDados("GPG", @aHeadMMM, @aColsMMM,@nUGPG, 1,, " GPG.GPG_CODPAR = '" + cCodPar + "' AND GPG.D_E_L_E_T_ <> '*' AND GPG.GPG_FILIAL = '" + xFilial("GPG") + "'",,,,,,,,,,,,,,, aCpoMMM,)
nCFGMMM :=   aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODSEQ"}) 
nMATMMM :=   aScan(aHeadMMM, {|aVet| aVet[2] == "GPG_CODMAT"}) 
cTitulo := "Selecione Configura็ใo de Meio de Coleta / Metodo / Mat. Biologico  "
  
DEFINE MSDIALOG oDlg TITLE cTitulo From 000, 000 To 300, 500 Of oMainWnd Pixel   
	 
	oGDMMM := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHeadMMM, aColsMMM)
	oGDMMM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
	oGDMMM:oBrowse:BlDblClick := { || nOpca := 1, oDlg:End() }
 		
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{ || nOpca := 1, oDlg:End() },{|| nOpca := 0, oDlg:End()})
	 
If nOpcA == 1
	aRet[1] := oGDMMM:aCols[oGDMMM:nAt, nCFGMMM]
	aRet[2] := oGDMMM:aCols[oGDMMM:nAt, nMATMMM]	
//	Return(aRet)
Else
	aRet[1] :=  cCodSeq
EndIf  

Inclui := .T.
 		
RestArea(aArea)
Return(aRet)


//HS_BusResp("GPI", {{"GPI->GPI_CDEXAM", oNewGetD:aCols[oNewGetD:oBrowse:nAt, nGBYSOLICI]}}, "GPI")
Function FS_HisResp(cCodPed,cAlias, cCpoRes, cIniCpo, cCdQues)
Local aArea 	:= GetArea()
Local nCpoChv 	:= 0, cCpoChv := ""//, cCpoRes := ""
Local cPrvVar 	:= "", cValRes := ""
Local aRetRes 	:= {}
Local cSql 	:= ""

cSql := " SELECT GBY_SOLICI FROM " + RetSqlName("GBY") + " GBY "
cSql += " WHERE GBY_CODPED = '" + cCodPed + "' AND GBY.D_E_L_E_T_ <> '*' AND GBY.GBY_FILIAL='" + xFilial("GBY") + "'"

cSql := ChangeQuery(cSql)

TCQUERY cSQL NEW ALIAS "TMPQRY"

While !TMPQRY->(Eof())
	DbSelectArea(cAlias)
	DbSetOrder(1)
	If DbSeek(xFilial(cAlias) + TMPQRY->GBY_SOLICI + cCdQues)	
		cCpoChv := TMPQRY->GBY_SOLICI
		Exit		
	EndIf	
	TMPQRY->(DbSkip())
EndDo

TMPQRY->(DbCloseArea())

If Empty(cCpoChv)
	Return(aRetRes)
EndIf

DbSelectArea(cAlias)
DbSetOrder(1)
DbSeek(xFilial(cAlias) + cCpoChv)

While !Eof() .And. cCpoChv == &(cCpoRes)
	
	If !Empty(HS_IniPadr("GCH", 1, &(cAlias + "->" + cAlias + "_CODPER"), "GCH_CODPER",, .F.))
		cPrvVar := AllTrim(cIniCpo + "_" + GCH->GCH_CODPER)
		
		If GCH->GCH_TIPPER == "C" // C=Caracter
			cValRes := &(cAlias + "->" + cAlias + "_RESCAR")
		ElseIf GCH->GCH_TIPPER == "N" // N=Numerico
			cValRes := VAL(&(cAlias + "->" + cAlias + "_RESNUM"))
		ElseIf GCH->GCH_TIPPER == "D" // D=Data
			cValRes := &(cAlias + "->" + cAlias + "_RESDAT")
		ElseIf GCH->GCH_TIPPER == "M" // M=Memo
			cValRes := &(cAlias + "->" + cAlias + "_RESMEM")
			If lTChr10
				cValRes := StrTran(cValRes, Chr(13) + Chr(10), Chr(13))
			EndIf
		EndIf
		
		_SetOwnerPrvt(cPrvVar, cValRes)
		aAdd(aRetRes, {"__" + GCH->GCH_TIPPER + cPrvVar, cValRes, GCH->GCH_DESPER})
	EndIf
	
	DbSkip()
End

RestArea(aArea)
Return(aRetRes)

