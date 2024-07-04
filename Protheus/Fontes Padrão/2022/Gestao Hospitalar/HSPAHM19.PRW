#INCLUDE "HSPAHM19.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM19  บAutor  ณAlessandro Freire   บ Data ณ  05/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de orcamentos                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao Hospitalar                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHM19()
 Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM19(.T.)})
 
 Local aCorM19 := {	{"GO0->GO0_STATUS == '0'", "BR_AMARELO"}, ;
                   		{"GO0->GO0_STATUS == '1'", "BR_VERDE"}, ;
                   		{"GO0->GO0_STATUS == '2'", "BR_VERMELHO"}}
 
 Private cCadastro := STR0001 // //"Or็amento de atendimento"
  
 Private aRotina := MenuDef()
 
 Private cFltM19 := ""
 
 If FS_FilM19(.F.)
  mBrowse(06, 01, 22, 75, "GO0",,,,,, aCorM19,,,,,,,, cFltM19)
 Endif
 
 SetKey(VK_F12, bKeyF12)  
 
Return(Nil)
                                             
/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MntM19 บAutor  ณAlessandro Freire   บ Data ณ  05/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de orcamentos                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MntM19(cAliasM19, nRegM19, nOpcM19)

Local oDlg     := nil
Local nOpcA    := 0
Local cChave   := ""
Local nGDOpc   := IIf((Inclui .Or. Altera) .And. nOpcM19 <> 8, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPObjs   := {}
Local aPFolder := {}
Local aGrava   := {}
Local aOk      := {}
Local lGravou  := .F.
Local aAltEnc  := {} 

Local aHMM := {}, aCMM := {}
Local aHTD := {}, aCTD := {}
Local aHPR := {}, aCPR := {}

Private nOpcRot  := nOpcM19
Private oEnchoice:= nil
Private oGDMM, oGDTD, oGDPR, nUMM := 0, nUTD := 0, nUPR := 0

Private oFolder := nil 
Private aGets   := {}
Private aTela   := {}

Private nMMCodLoc := 0, nMMNomLoc := 0, nMMItem   := 0, nMMQtdDes := 0, nMMValDes := 0, nMMCodDes := 0, nMMDDespe := 0, nMMCodPct := 0, nMMDesPct := 0, nMMCodKit := 0, nMMDesKit := 0
Private nTDCodLoc := 0, nTDNomLoc := 0, nTDItem   := 0, nTDQtdDes := 0, nTDValDes := 0, nTDCodDes := 0, nTDDDespe := 0, nTDCodPct := 0, nTDDesPct := 0
Private nPRCodLoc := 0, nPRNomLoc := 0, nPRItem   := 0, nPRQtdDes := 0, nPRValDes := 0, nPRCodDes := 0, nPRDDespe := 0
Private nPRSPrinc := 0, nPRDatDes := 0, nPRHorDes := 0, nPRCodAto := 0, nPRDesAto := 0, nPRCoefAM := 0, nPRVCusOp := 0
Private nPRVFilme := 0, nPRCodVia := 0, nPRCodPct := 0, nPRDesPct := 0
Private cGbhDtNasc := "", cGbhSexo   := ""

Private cPrefiMM := "GO5->GO5", cPrefiTD := "GO6->GO6", cPrefiPR := "GO7->GO7"
Private cGczCodPla := "", cLctCodLoc := "", cGcsCodLoc := "", cGcsArmSet := "", cGcyAtendi := ""

Private __aRMatMed := {	{"oGDMM:aCols[oGDMM:nAt, nMMDDESPE]", "06"}, ;
                       		{"oGDMM:aCols[oGDMM:nAt, nMMVALDES]", "02"}}
                       
Private __aRTaxDia := {	{"oGDTD:aCols[oGDTD:nAt, nTDDDESPE]", "06"}, ;
                       		{"oGDTD:aCols[oGDTD:nAt, nTDVALDES]", "02"}}
                       
Private __aRProced := {	{"oGDPR:aCols[oGDPR:nAt, nPRDDESPE]", "06"        }, ;
                       		{"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"}, ;
                       		{"oGDPR:aCols[oGDPR:nAt, nPRVFILME]", "02, 03"    }, ;
                       		{"oGDPR:aCols[oGDPR:nAt, nPRVCUSOP]", "02, 02"    }, ;
                       		{"oGDPR:aCols[oGDPR:nAt, nPRCOEFAM]", "02, 01, 02"}}

Private __cFCdBKit := "HS_M24Kit()" 					// Sera utilizado dentro da fun็ใo de valida็ใo do c๓digo de barras do 
Private __cFVPrPct := "HS_M24Pct()" 					// Sera utilizado dentro da fun็ใo de valida็ใo do procedimento e da taxa/diaria
Private __cFMntEqp := "HS_MntEqp(oGDPr)"	// Sera utilizado dentro da fun็ใo de valida็ใo do procedimento

Private cGcsTipLoc := ""

/* Divide a janela */
aSize    := MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 050, .T., .T. } )
AAdd( aObjects, { 100, 050, .T., .T., .T. } )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs   := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

/* Armazena a posicao da getdados dentro do folder */
aInfo    := { 2, 2, aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPFolder := MsObjSize( aInfo, aObjects )
                          
/* Copiar */
If nOpcRot == 6
 Inclui := .F.
EndIf

RegToMemory("GO0", Inclui)

cGcsTipLoc := M->GO0_ATENDI

cGcsCodLoc := IIF(nOpcRot == 7, GO0->GO0_CODLOC, M->GO0_CODLOC)
cLctCodLoc := IIF(nOpcRot == 7, GO0->GO0_CODLOC, M->GO0_CODLOC)
cGczCodPla := IIF(nOpcRot == 7, GO0->GO0_CODPLA, M->GO0_CODPLA)
cGcyAtendi := IIF(nOpcRot == 7, GO0->GO0_ATENDI, M->GO0_ATENDI)

// Monta aHeader e aCols
HS_BDados("GO5",   @aHMM,  @aCMM,  @nUMM, 1, M->GO0_NUMORC, IIf(nOpcRot == 7, Nil, "GO5->GO5_NUMORC == '" + M->GO0_NUMORC + "'"))
HS_BDados("GO6",   @aHTD,  @aCTD,  @nUTD, 1, M->GO0_NUMORC, IIf(nOpcRot == 7, Nil, "GO6->GO6_NUMORC == '" + M->GO0_NUMORC + "'"))
HS_BDados("GO7",   @aHPR,  @aCPR,  @nUPR, 1, M->GO0_NUMORC, IIf(nOpcRot == 7, Nil, "GO7->GO7_NUMORC == '" + M->GO0_NUMORC + "'"))


If nOpcRot == 7 // Gerar
 // Gera os orcamentos
	If !FS_GERAORC( @aHMM, @aCMM, @aHTD, @aCTD, @aHPR, @aCPR )
		Return(.f.)
	EndIf
EndIf

nMMCodLoc := aScan( aHMM, {|x| x[2] == "GO5_CODLOC" } )
nMMNomLoc := aScan( aHMM, {|x| x[2] == "GO5_NOMLOC" } )
nMMItem   := aScan( aHMM, {|x| x[2] == "GO5_ITEM  " } )  
nMMQtdDes := aScan( aHMM, {|x| x[2] == "GO5_QTDDES" } )  
nMMCodDes := aScan( aHMM, {|x| x[2] == "GO5_CODDES" } )  
nMMValDes := aScan( aHMM, {|x| x[2] == "GO5_VALDES" } )
nMMDDespe := aScan( aHMM, {|x| x[2] == "GO5_DDESPE" } )
nMMCodPct := aScan( aHMM, {|x| x[2] == "GO5_CODPCT" } )
nMMDesPct := aScan( aHMM, {|x| x[2] == "GO5_DESPCT" } )
nMMCodKit := aScan( aHMM, {|x| x[2] == "GO5_CODKIT" } )
nMMDesKit := aScan( aHMM, {|x| x[2] == "GO5_DESKIT" } )
                                                         
nTDCodLoc := aScan( aHTD, {|x| x[2] == "GO6_CODLOC" } )
nTDNomLoc := aScan( aHTD, {|x| x[2] == "GO6_NOMLOC" } )
nTDItem   := aScan( aHTD, {|x| x[2] == "GO6_ITEM  " } )  
nTDQtdDes := aScan( aHTD, {|x| x[2] == "GO6_QTDDES" } )  
nTDCodDes := aScan( aHTD, {|x| x[2] == "GO6_CODDES" } )  
nTDValDes := aScan( aHTD, {|x| x[2] == "GO6_VALDES" } )
nTDDDespe := aScan( aHTD, {|x| x[2] == "GO6_DDESPE" } )
nTDCodPct := aScan( aHTD, {|x| x[2] == "GO6_CODPCT" } )
nTDDesPct := aScan( aHTD, {|x| x[2] == "GO6_DESPCT" } )
nTDCodKit := aScan( aHTD, {|x| x[2] == "GO6_CODKIT" } )
nTDDesKit := aScan( aHTD, {|x| x[2] == "GO6_DESKIT" } )

nPRCodLoc := aScan( aHPR, {|x| x[2] == "GO7_CODLOC" } )
nPRNomLoc := aScan( aHPR, {|x| x[2] == "GO7_NOMLOC" } )
nPRDatDes := aScan( aHPR, {|x| x[2] == "GO7_DATDES" } )
nPRHorDes := aScan( aHPR, {|x| x[2] == "GO7_HORDES" } )
nPRItem   := aScan( aHPR, {|x| x[2] == "GO7_ITEM  " } )  
nPRQtdDes := aScan( aHPR, {|x| x[2] == "GO7_QTDDES" } )  
nPRCodDes := aScan( aHPR, {|x| x[2] == "GO7_CODDES" } )  
nPRValDes := aScan( aHPR, {|x| x[2] == "GO7_VALDES" } )
nPRDDespe := aScan( aHPR, {|x| x[2] == "GO7_DDESPE" } )
nPRSPrinc := aScan( aHPR, {|x| x[2] == "GO7_SPRINC" } )
nPRCodAto := aScan( aHPR, {|x| x[2] == "GO7_CODATO" } )
nPRDesAto := aScan( aHPR, {|x| x[2] == "GO7_DESATO" } )                                 
nPRCoefAM := aScan( aHPR, {|x| x[2] == "GO7_COEFAM" } )                                 
nPRVCusOp := aScan( aHPR, {|x| x[2] == "GO7_VCUSOP" } )
nPRVFilme := aScan( aHPR, {|x| x[2] == "GO7_VFILME" } )
nPRCodVia := aScan( aHPR, {|x| x[2] == "GO7_CODVIA" } )
nPRCodPct := aScan( aHPR, {|x| x[2] == "GO7_CODPCT" } )
nPRDesPct := aScan( aHPR, {|x| x[2] == "GO7_DESPCT" } )

If Empty(aCMM[1, nMMItem])
 aCMM[1, nMMItem] := Soma1(aCMM[1, nMMItem], Len(aCMM[1, nMMItem]))
EndIf                       

If Empty(aCTD[1, nTDItem])
 aCTD[1, nTDItem] := Soma1(aCTD[1, nTDItem], Len(aCTD[1, nTDItem]))
EndIf

If Empty(aCPR[1, nPRItem])
 aCPR[1, nPRItem] := Soma1(aCPR[1, nPRItem], Len(aCPR[1, nPRItem]))
EndIf 

If nOpcRot == 6 // Copiar 
 Inclui := .T.
 M->GO0_NUMORC := CriaVar("GO0_NUMORC")
 M->GO0_DATORC := CriaVar("GO0_DATORC")
 M->GO0_HORORC := CriaVar("GO0_HORORC")
 M->GO0_DATPRE := CriaVar("GO0_DATPRE")
 M->GO0_HORPRE := CriaVar("GO0_HORPRE")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Campos que deverao ser editados na Enchoice                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcRot == 8 
 Aadd(aAltEnc,"GO0_CDREJE")  
EndIf

Define MsDialog oDlg Title OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd PIXEL

 oEnchoice := MsMGet():New("GO0", nRegM19, nOpcRot,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, IIF(Len(aAltEnc) > 0, aAltEnc, Nil),2,,,,oDlg)
 oEnchoice:oBox:Align := CONTROL_ALIGN_TOP
 oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GO0_ATENDI" $ aVet})]:BLOSTFOCUS := {|| !Empty(cGcyAtendi := M->GO0_ATENDI)}
 
 @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0012, STR0010, STR0011 //"&3-Procedimentos"###"&4 - Materiais / Medicamentos"###"&5-Taxas / Diarias"
 oFolder:Align := CONTROL_ALIGN_ALLCLIENT
 
 oGDPR := MsNewGetDados():New(aPFolder[1, 1], aPFolder[1, 2], aPFolder[1, 3], aPFolder[1, 4], nGDOpc,,, "+GO7_ITEM",,, 99999,,,, oFolder:aDialogs[1], aHPR, aCPR)
 oGDPR:oBrowse:bDelOk := {|| FS_VlExcGD("P")} 
 oGDPR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 oGDMM := MsNewGetDados():New(aPFolder[1, 1], aPFolder[1, 2], aPFolder[1, 3], aPFolder[1, 4], nGDOpc,,, "+GO5_ITEM",,, 99999,,,, oFolder:aDialogs[2], aHMM, aCMM)
 oGDMM:oBrowse:bDelOk := {|| FS_VlExcGD("M")} 
 oGDMM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 oGDTD := MsNewGetDados():New(aPFolder[1, 1], aPFolder[1, 2], aPFolder[1, 3], aPFolder[1, 4], nGDOpc,,, "+GO6_ITEM",,, 99999,,,, oFolder:aDialogs[3], aHTD, aCTD)
 oGDTD:oBrowse:bDelOk := {|| FS_VlExcGD("T")}
 oGDTD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 
 oDlg:bStart := { || IIF(nOpcRot == 7, HS_ATUDESP(), Nil)} 

Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And.;
                                                                    HS_TudoOK("GO5", oGDMM, nMMCodDes) .And. ;
                                                                    HS_TudoOK("GO6", oGDTD, nTDCodDes) .And. ;
                                                                    HS_TudoOK("GO7", oGDPR, nPRCodDes) .And. ;
                                                                    FS_VLDOK() .And.;
                                                                    IIF(nOpcRot == 8, FS_VldRej(), .T.), ;  
                                                                    oDlg:End(), nOpcA := 0)},;
                                                 {|| nOpcA := 0, oDlg:End()} )

IF nOpcA == 0
	While __lSx8
		RollBackSxe()
	End
Else 
 If nOpcRot == 8 //Rejeitar
  FS_RejM19()
 
	ElseIf nOpcRot != 2 // Caso nao seja consulta entra na funcao de gravacao
	
		Begin Transaction
 		lGravou := FS_GrvM19()
		End Transaction
		
		If lGravou
 		While __lSx8
	 		ConfirmSx8()
		 End
		Else
 		While __lSx8
	  	RollBackSxe()
	  End
		EndIf 
	EndIf                   

 If nOpcRot == 6 .or. nOpcRot == 7 // Copiar ou Gerar
  MBrChgLoop(.F.)
 EndIf 
 
 If nOpcRot == 3 .And. lGravou .And. Pergunte("HSP19A",.T.)
  HS_DocsOrc(MV_PAR01) 
 EndIf
  
EndIf

DbSelectArea("GO0")
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvM19 บ Autor ณAlessandro Freire   บ Data ณ  01/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava os orcamentos                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvM19()
 Local cAliasOld := Alias(), nConta := 0, nItens := 0
                                      	
 If (Empty( oGDMM:aCols ) .and. Empty( oGDTD:aCols ) .and. Empty( oGDPR:aCols )) .Or. ;
  (EMPTY(oGDMM:aCols[1, nMMCodDes]) .And. EMPTY(oGDTD:aCols[1, nTDCodDes]) .And. EMPTY(oGDPR:aCols[1, nPRCodDes]))
  HS_MsgInf(STR0013,STR0034,STR0001) // //"Nใo foi informado nenhum item para este or็amento"###Atencao"###"Or็amento de atendimento"
  Return(.F.)
 EndIf 
 
 // Valida se ha pelo menos uma linha sem deletar
 For nItens := 1 to Len(oGDMM:aCols) 
 	If oGDMM:aCols[nItens, Len(oGDMM:aCols[nItens])]
 		nConta ++
 	EndIf
 Next nItens

 For nItens := 1 to Len(oGDTD:aCols) 
 	If oGDTD:aCols[nItens, Len(oGDTD:aCols[nItens])]
 		nConta ++
 	EndIf
 Next nItens

 For nItens := 1 to Len(oGDPR:aCols) 
 	If oGDPR:aCols[nItens, Len(oGDPR:aCols[nItens])]
 		nConta ++
 	EndIf
 Next nItens

	If nConta == (Len(oGDMM:aCols) + Len(oGDTD:aCols) + Len(oGDPR:aCols) )
		HS_MsgInf(STR0014,STR0034,STR0001) // //"Nใo hแ nenhum item a ser gravado para este or็amento"###Atencao"###"Or็amento de atendimento"
		Return(.F.)
 EndIf

 If Inclui .Or. Altera
	 If Inclui
	 	M->GO0_NUMORC := HS_VSxeNum("GO0", "M->GO0_NUMORC", 1)
	 EndIf
		
	 RecLock("GO0", Inclui)
  	HS_GRVCPO("GO0")
	 MsUnlock()
		                                            
	 FS_GrvGD("GO5", 1, oGDMM, nMMItem, nMMCodLoc, nMMCodDes)
	 FS_GrvGD("GO6", 1, oGDTD, nTDItem, nTDCodLoc, nTDCodDes)
	 FS_GrvGD("GO7", 1, oGDPR, nPRItem, nPRCodLoc, nPRCodDes)
	Else     
		FS_DelGD("GO5", "GO5_NUMORC = '" + GO0->GO0_NUMORC + "'")
		FS_DelGD("GO6", "GO6_NUMORC = '" + GO0->GO0_NUMORC + "'")
		FS_DelGD("GO7", "GO7_NUMORC = '" + GO0->GO0_NUMORC + "'")
		
		RecLock("GO0", .F., .F.)
 		DbDelete()
		MsUnLock()
		WriteSx2("GO0")
	Endif

 DbSelectArea(cAliasOld)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGD  บAutor  ณMicrosiga           บ Data ณ  05/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os itens da getdados do orcamento                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvGD(cAlias, nOrdem, oItens, nGDItem, nGDCodLoc, nGDCodDes)
Local nForItens := 0, cPArq := cAlias + "->" + PrefixoCpo(cAlias), lFound := .f.
Local cSPrinc := "", cAtPrinc := "XXXXXX", nLSPrinc := 0, aCtrlVias := {}, aRAtoMed := {}

If cAlias == "GO7"
 nLSPrinc := HS_CfgSx3(oGDPR:aHeader[nPRSPrinc, 2])[SX3->(FieldPos("X3_TAMANHO"))]
EndIf 

For nForItens := 1 To Len(oItens:aCols)
	DbSelectArea(cAlias)
	DbSetOrder(nOrdem)
	lFound := DbSeek(xFilial(cAlias) + M->GO0_NUMORC + oItens:aCols[nForItens, nGdItem])
		
	If !oItens:aCols[nForItens, Len(oItens:aCols[nForItens])] .And. !EMPTY(oItens:aCols[nForItens, nGDCodLoc]) .And. ;
   	!EMPTY(oItens:aCols[nForItens, nGDCodDes])
		RecLock(cAlias, !lFound)
		 HS_GRVCPO(cAlias, oItens:aCols, oItens:aHeader, nForItens)
		 &(cPArq + "_FILIAL") := xFilial(cAlias)
			&(cPArq + "_NUMORC") := M->GO0_NUMORC
			&(cPArq + "_LOGARQ") := HS_LogArq()
			
			If cAlias == "GO7" .And. M->GO0_NUMORC + oItens:aCols[nForItens, nPRItem] # oItens:aCols[nForItens, nPRSPrinc]
    If oItens:aCols[nForItens, nPRSPrinc] == StrZero(nForItens, nLSPrinc)
     cSPrinc  := M->GO0_NUMORC + oItens:aCols[nForItens, nPRItem]
     cAtPrinc := StrZero(nForItens, nLSPrinc)
     GO7->GO7_SPRINC := cSPrinc
    ElseIf oItens:aCols[nForItens, nPRSPrinc] == cAtPrinc
     GO7->GO7_SPRINC := cSPrinc
    EndIf 
   EndIf 
		MsUnlock()
		
		If cAlias == "GO7" // Se for procedimento grava matriz para calculo de vias de acesso  
		 aRValDes := HS_RValPr(oItens:aCols[nForItens, nPRCodDes], M->GO0_CODPLA, oItens:aCols[nForItens, nPRCodLoc], ;
		                       oItens:aCols[nForItens, nPRHorDes],"0",, oItens:aCols[nForItens, nPRCodAto], ;
		                       {M->GO0_ATENDI, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO}, .F., oItens:aCols[nForItens, nPRDatDes])
		                       
   aRAtoMed := HS_RAtoMed(1, oItens:aCols[nForItens, nPRCodAto] + "1", .T.) // 1-Ativo
   
   If aRValDes[13] .And. !Empty(oItens:aCols[nForItens, nPRCodVia]) .And. (Empty(oItens:aCols[nForItens, nPRCodAto]) .Or. aRAtoMed[3] == "0") // 0-Cirurgiใo
    If (nPosVias := aScan(aCtrlVias, {| aVet | aVet[1] == oItens:aCols[nForItens, nPRDatDes]})) == 0
     aAdd(aCtrlVias, {oItens:aCols[nForItens, nPRDatDes], Replicate("X" , Len(GBJ->GBJ_CRM)), {}})
     nPosVias := Len(aCtrlVias)
    EndIf
    aAdd(aCtrlVias[nPosVias][3], {aRValDes[2][1][1], oItens:aCols[nForItens, nPRCodVia], M->GO0_NUMORC + oItens:aCols[nForItens, nPRItem], 0, 0, oItens:aCols[nForItens, nPRSPrinc], oItens:aCols[nForItens, nPRCodDes]})
   EndIf 
  EndIf 
	Else
		If lFound
			RecLock(cAlias, .F., .F.)
 			DbDelete()
			MsUnLock()
			WriteSx2(cAlias)
		EndIf
	EndIf
Next                
                       
If cAlias == "GO7"
 HS_CalcVias(aCtrlVias, "GO7", {1, 2},,, .T.) // Efetua calculo de vias
EndIf

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfs_delgd  บAutor  ณAlessandro Freire   บ Data ณ  05/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga os registros de orcamento                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DelGD(cAlias, cCond)
 TCSQLExec("UPDATE " + RetSqlName(cAlias) + " SET D_E_L_E_T_ = '*' WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cCond)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_vldm19 บAutor  ณJose Orfeu          บ Data ณ  05/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao dos campos da enchoice e das getdados            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAntonio Carlosณ28/06/06ณ XXXX ณNa informa็ใo de um c๓digo de prontuแrioณฑฑ
ฑฑณ              ณ        ณ      ณatualizar, al้m do nome, o sexo  e  dataณฑฑ
ฑฑณ              ณ        ณ      ณde nascimento do paciente, a  partir		doณฑฑ
ฑฑณ              ณ        ณ      ณcadastro (GBH)                         	ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldM19()

Local lRet := .T., cAliasOld := Alias(), cGoNomLoc := ""
Local nForD := 0
Local aRVldVig	:= {}
Local lIteKit  := .F.                   
 
If ReadVar() == "M->GO0_REGGER" // Valida็ใo do prontuario do paciente
 If Empty(M->GO0_REGGER)
  M->GO0_NOMPAC := SPACE(LEN(GO0->GO0_NOMPAC))
 ElseIf !(lRet := HS_SeekRet("GBH", "M->GO0_REGGER", 1, .F., "GO0_NOMPAC", "GBH_NOME"))
  HS_MsgInf(STR0015, STR0066, STR0067) //"Prontuario nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 Else
  M->GO0_SEXO   := GBH->GBH_SEXO
  M->GO0_DTNASC := GBH->GBH_DTNASC  
  M->GO0_FONE   := GBH->GBH_TEL
  M->GO0_IDADE  := HS_AgeGer(M->GO0_DTNASC, DDATABASE)
  DbSelectArea("GD4")
  DbSetOrder(2)
 	DbSeek(xFilial("GD4") + M->GO0_REGGER + "1") // pega convenio/plano padrao do paciente
  M->GO0_CODPLA := GD4->GD4_CODPLA
  cGczCodPla := M->GO0_CODPLA 
 EndIf                 

ElseIf ReadVar() == "M->GO0_DTNASC" // Valida็ใo da data de nascimento
 M->GO0_IDADE := HS_AgeGer(M->GO0_DTNASC, dDataBase)
ElseIf ReadVar() == "M->GO0_CODPLA" // Validacao do plano
 If !(lRet := HS_SEEKRET("GCM", "M->GO0_CODPLA", 2, .F., "GO0_DESPLA", "GCM_DESPLA"))
  HS_MsgInf(STR0016, STR0066, STR0067) //"Plano nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 Else
  cGczCodPla := M->GO0_CODPLA 
 EndIf            

ElseIf ReadVar() == "M->GO0_CODPRO" // Validacao do codigo do procedimento do orcamento
 If !(lRet := HS_SeekRet("GA7", "M->GO0_CODPRO", 1, .f., "GO0_DESPRO", "GA7_DESC"))
  HS_MsgInf(STR0017, STR0066, STR0067) //"Procedimento nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 Else  
  cGbhDtNasc := M->GO0_DTNASC 
  cGbhSexo   := M->GO0_SEXO 
  HS_VProced(M->GO0_CODPLA, M->GO0_CODLOC, M->GO0_CODPRO)
  If len(oGDPR:aCols)<=1 
   If Empty(oGDPR:aCols[oGDPR:nAT, nPRCodDes])
    oGDPR:aCols[oGDPR:nAt, nPRDDESPE] := SPACE(LEN(GA7->GA7_DESC))
    oGDPR:aCols[oGDPR:nAt, nPRVALDES] := 0
    oGDPR:aCols[oGDPR:nAt, nPRVFILME] := 0
    oGDPR:aCols[oGDPR:nAt, nPRVCUSOP] := 0
    oGDPR:aCols[oGDPR:nAt, nPRCOEFAM] := 0
    oGDPR:oBrowse:Refresh()
   Endif
  Endif 
 
 EndIf

ElseIf ReadVar() == "M->GO0_ATENDI" //Validacao do tipo de atendimento 
 If !(lRet := M->GO0_ATENDI $ ("0/1/2"))
  HS_MsgInf(STR0068, STR0066, STR0067) //"Tipo do atendimento invalido"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 Else
  cGcsTipLoc := M->GO0_ATENDI 
 Endif 

ElseIf ReadVar() $ "M->GO0_CODLOC/M->GO5_CODLOC/M->GO6_CODLOC/M->GO7_CODLOC" // Validacao do setor
 cLctCodLoc := &(ReadVar())
 cGcsCodLoc := &(ReadVar())
 If SubStr(ReadVar(), 4, 3) == "GO0"
  If HS_IniPadr("GCS", 1, M->GO0_CODLOC, "GCS_TIPLOC",, .F.)	<> M->GO0_ATENDI  
   HS_MsgInf(STR0078, STR0066, STR0067) //"Tipo do setor diferente do tipo do atendimento"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
   Return(.F.)
  EndIf

  cGoNomLoc := "M->GO0_NOMLOC"
  If EMPTY(oGDMM:aCols[1, nMMCodLoc]) 
   oGDMM:aCols[1, nMMCodLoc] := cLctCodLoc
   oGDMM:aCols[1, nMMNomLoc] := HS_IniPadr("GCS", 1, cLctCodLoc, "GCS_NOMLOC",, .F.)	  
   oGDMM:oBrowse:Refresh()
  EndIf
  If EMPTY(oGDTD:aCols[1, nTDCodLoc])
   oGDTD:aCols[1, nTDCodLoc] := cLctCodLoc
   oGDTD:aCols[1, nTDNomLoc] := HS_IniPadr("GCS", 1, cLctCodLoc, "GCS_NOMLOC",, .F.)	  
   oGDTD:oBrowse:Refresh()   
  EndIf
  If EMPTY(oGDPR:aCols[1, nPRCodLoc]) 
   oGDPR:aCols[1, nPRCodLoc] := cLctCodLoc
   oGDPR:aCols[1, nPRNomLoc] := HS_IniPadr("GCS", 1, cLctCodLoc, "GCS_NOMLOC",, .F.)	  
   oGDPR:oBrowse:Refresh()
  EndIf
 ElseIf SubStr(ReadVar(), 4, 3) == "GO5"
  cGoNomLoc := "oGDMM:aCols[oGDMM:nAt, nMMNomLoc]"
 ElseIf SubStr(ReadVar(), 4, 3) == "GO6"
  cGoNomLoc := "oGDTD:aCols[oGDTD:nAt, nTDNomLoc]"
 ElseIf SubStr(ReadVar(), 4, 3) == "GO7"
  cGoNomLoc := "oGDPR:aCols[oGDPR:nAt, nPRNomLoc]"
 EndIf
 If !(lRet := !Empty(&(ReadVar())))
		HS_MsgInf(STR0069, STR0066, STR0067) //"O c๓digo do setor ้ obrigat๓rio"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	ElseIf !(lRet := HS_SeekRet("GCS","'" + &(ReadVar()) + "'", 1, .F., cGoNomLoc, "GCS_NOMLOC"))
		HS_MsgInf(STR0053, STR0066, STR0067) //"Setor nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	EndIf
	//Revalorizacao do item de despesa
 If SubStr(ReadVar(), 4, 3) == "GO6" .and. !Empty(oGDTD:aCols[oGDTD:nAT, nTDCODDES])
  lRet := FS_Revalor("GO6", oGDTD:nAT, M->GO0_CODPLA, oGDTD:aCols[oGDTD:nAT, nTDCodDes], ;
                      M->GO0_DATPRE, M->GO6_CODLOC)
 ElseIf SubStr(ReadVar(), 4, 3) == "GO7" .and. !Empty(oGDPR:aCols[oGDPR:nAT, nPRCODDES]) ;
                                          .and. !Empty(oGDPR:aCols[oGDPR:nAT, nPRDATDES])
  lRet := FS_Revalor("GO7", oGDPR:nAT, M->GO0_CODPLA, oGDPR:aCols[oGDPR:nAT, nPRCodDes], ;
                             oGDPR:aCols[oGDPR:nAT, nPRDATDES], M->GO7_CODLOC, ;
                             oGDPR:aCols[oGDPR:nAT, nPRCODATO], {M->GO0_ATENDI, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO})
 Endif 

ElseIf ReadVar() == "M->GO5_CODDES" // Validaca do Material
 If !(lRet := !Empty(M->GO5_CODDES))
		HS_MsgInf(STR0018, STR0066, STR0067) //"O codigo do mat/med ้ obrigatorio"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	ElseIf !(lRet := HS_SeekRet("SB1","M->GO5_CODDES", 1, .F., "GO5_DDESPE", "B1_DESC"))
		HS_MsgInf(STR0019, STR0066, STR0067) //"Mat/Med nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	Else
	 If (lIteKit := Len((__aIteKit := HS_RKitMMP(SB1->B1_COD, HS_M24LocK("GO5")))[1]) > 0)
 		If Type("__cFCdBKit") # "U"
	 		&(__cFCdBKit)
	 	EndIf
	 EndIf
	 If !lIteKit
	  lRet := HS_VMatMed(M->GO0_CODPLA, M->GO5_CODDES, , , , , , M->GO0_DATPRE, oGDMM:aCols[oGDMM:nAT, nMMCODLOC])
		Endif 
	EndIf

ElseIf ReadVar() == "M->GO6_CODDES" // Validacao da taxa/diaria
 If !(lRet := !Empty(M->GO6_CODDES))
		HS_MsgInf(STR0070, STR0066, STR0067) //"O c๓digo da taxa/diaria ้ obrigatorio"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	ElseIf !(lRet := HS_SeekRet("GAA","M->GO6_CODDES", 1, .F., "GO6_DDESPE", "GAA_DESC"))
		HS_MsgInf(STR0021, STR0066, STR0067) //"Taxa/Diaria nใo encontrada"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	Else
  lRet := HS_VTaxDia(M->GO0_CODPLA, oGDTD:aCols[oGDTD:nAt, nTDCodLoc], M->GO6_CODDES, , , ,M->GO0_DATPRE)
   
 Endif
ElseIf ReadVar() == "M->GO7_CODDES" // Validaca do Material
 If !(lRet := !Empty(M->GO7_CODDES))
		HS_MsgInf(STR0071, STR0066, STR0067) //"O c๓digo do procedimento ้ obrigat๓rio"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	ElseIf !(lRet := HS_SeekRet("GA7","M->GO7_CODDES", 1, .F., "GO7_DDESPE", "GA7_DESC"))
		HS_MsgInf(STR0017, STR0066, STR0067) //"Procedimento nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	Else
  cGbhSexo   := M->GO0_SEXO 
  lRet := HS_VProced(M->GO0_CODPLA, oGDPR:aCols[oGDPR:nAt, nPRCodLoc], M->GO7_CODDES, , , ,"0" , , oGDPR:aCols[oGDPR:nAt, nPRCODATO], ;
                         {M->GO0_ATENDI, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO}, , oGDPR:aCols[oGDPR:nAt, nPRDATDES])
                                                      
	EndIf                 

ElseIf ReadVar() == "M->GO7_CODVIA"
 IF !(lRet := HS_SeekRet("GE4","M->GO7_CODVIA", 1, .F., "GO7_DESVIA", "GE4_DESVIA",,, .T.))
	 HS_MsgInf(STR0054, STR0066, STR0067) //"Via de acesso nao encontrada"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
	EndIf	

ElseIf ReadVar() == "M->GO7_CODATO" // Validacao do codigo do ato medico
 If !(lRet := HS_SeekRet("GMC", "M->GO7_CODATO", 1, .F., "GO7_DESATO", "GMC_DESATO"))
  HS_MsgInf(STR0072, STR0066, STR0067) //"Ato m้dico nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 Else
  If !Empty(oGDPR:aCols[oGDPR:nAT, nPRCODDES]) .and. !Empty(oGDPR:aCols[oGDPR:nAT, nPRDATDES]) ;
                                                .and. !Empty(oGDPR:aCols[oGDPR:nAT, nPRCODLOC])                                       
    lRet := FS_Revalor("GO7", oGDPR:nAT, M->GO0_CODPLA, oGDPR:aCols[oGDPR:nAT, nPRCodDes], ;
                                oGDPR:aCols[oGDPR:nAT, nPRDATDES], oGDPR:aCols[oGDPR:nAT, nPRCODLOC], ;
                                M->GO7_CODATO, {M->GO0_ATENDI, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO})
  EndIf
 Endif 

ElseIf ReadVar() == "M->GO7_DATDES" // Validacao da data do procedimento
 If !Empty(oGDPR:aCols[oGDPR:nAT, nPRCODDES]) .and. !Empty(oGDPR:aCols[oGDPR:nAT, nPRCODLOC])                                       
  lRet := FS_Revalor("GO7", oGDPR:nAT, M->GO0_CODPLA, oGDPR:aCols[oGDPR:nAT, nPRCodDes], ;
                                                     M->GO7_DATDES, oGDPR:aCols[oGDPR:nAT, nPRCODLOC], ;
                                                     oGDPR:aCols[oGDPR:nAT, nPRCODATO], {M->GO0_ATENDI, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO})
 Endif 

ElseIf ReadVar() == "M->GO0_CODCRM" // Validacao do CRM
 If !(lRet := HS_SeekRet("SRA", "M->GO0_CODCRM", 11, .f., "GO0_NOMMED", "RA_NOME"))
  HS_MsgInf(STR0073, STR0066, STR0067) //"M้dico nใo encontrado"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 EndIf
 
ElseIf ReadVar() == "M->GO0_CDREJE" // Validacao do codigo da rejeicao
 If !(lRet := HS_SeekRet("GES", "M->GO0_CDREJE", 1, .f., "GO0_DSREJE", "GES_DESCRI"))
  HS_MsgInf(STR0074, STR0066, STR0067) //"Rejei็ใo nใo encontrada"###"Aten็ใo"###"Valida็๕es dos campos do or็amento"
 EndIf

EndIf
                                            
//Revalorizacao de todos os itens de despesa, em funcao da alteracao dos campos ATENDI e CODPLA
If lRet .and. Readvar() $ ("M->GO0_ATENDI/M->GO0_CODPLA/M->GO0_DATPRE")

 If ReadVar() <> "M->GO0_ATENDI" //ATENDI so eh utilizado para procedimentos
  If len(oGDMM:aCols) > 1 .or. (len(oGDMM:aCols) == 1 .and. !Empty(oGDMM:aCols[1, nMMCODDES]))
   For nForD := 1 to len(oGDMM:aCols) //Revalorizacao das despesas de Mat/Med
    If !(lRet := FS_Revalor("GO5", nForD, M->GO0_CODPLA, oGDMM:aCols[nForD, nMMCodDes],,oGDMM:aCols[nForD, nMMCODLOC],, ;
    {M->GO0_DATPRE, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO}))
     Exit
    Endif 
   Next nForD
  Endif 
 Endif 
                                
 If lRet .and. ReadVar() <> "M->GO0_ATENDI"  //ATENDI so eh utilizado para procedimentos
  If len(oGDTD:aCols) > 1 .or. (len(oGDTD:aCols) == 1 .and. !Empty(oGDTD:aCols[1, nTDCODDES]))
   For nForD := 1 to len(oGDTD:aCols) //Revalorizacao das despesas de Tax/Dia
    If !(lRet := FS_Revalor("GO6", nForD, M->GO0_CODPLA, oGDTD:aCols[nForD, nTDCodDes], ;
                      M->GO0_DATPRE, oGDTD:aCols[nForD, nTDCODLOC]))
     Exit
    Endif                       
   Next nForD
  Endif 
 Endif 
                                                                     
 If lRet .and. ReadVar() <> "M->GO0_DATPRE" //Para procedimentos, nao faz pela GO0_DATPRE e sim pela GO7_DATDES
  If len(oGDPR:aCols) > 1 .or. (len(oGDPR:aCols) == 1 .and. !Empty(oGDPR:aCols[1, nPRCODDES]))
   For nForD := 1 to len(oGDPR:aCols) //Revalorizacao das despesas de Pro/Hon
    If (lRet := FS_Revalor("GO7", nForD, M->GO0_CODPLA, oGDPR:aCols[nForD, nPRCodDes], ;
                             oGDPR:aCols[nForD, nPRDATDES], oGDPR:aCols[nForD, nPRCODLOC], ;
                             oGDPR:aCols[nForD, nPRCODATO], {M->GO0_ATENDI, M->GO0_ATENDI, M->GO0_IDADE, M->GO0_SEXO}))
     Exit
    Endif                              
   Next nForD
  Endif
 Endif 

Endif
             
 HS_ATUDESP()

oEnchoice:Refresh()
DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GERAORCบ Autor ณAlessandro Freire   บ Data ณ 02/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera o orcamento a partir das guias do GCZ                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Retorno:
aArray
[1] - .f. - cancelado, .t. ok
[2] - Numero sequencial da guia no GCZ
[3] - Prefixo das tabelas de despesas. Pode ser "GD" ou "GE"

/*/
Function FS_GERAORC( aHMM, aCMM, aHTD, aCTD, aHPR, aCPR )
Local aArea      := GetArea()
Local nOpca      := 0
Local aHGCZ      := {}
Local aCGCZ      := {}
Local nUGCZ      := 0 
Local cFilM19    := "" 
Local nGczNrSeqG := 0, nGczRegAte := 0
Local nGczTotPro := 0, nGczTotTxd := 0, nGczTotMat := 0, nGczTotMed := 0, nGczTotGui := 0
Local vGczTotPro := 0, vGczTotTxd := 0, vGczTotMat := 0, vGczTotMed := 0, vGczTotGui := 0
Local oGDGCZ     := Nil, nForGuias := 0, nTotGuias  := 0

Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPObj      := {}                  
Local aTabPre    := {}
Local cLstCpo    := ""
Local cCposGrpBy := ""
Local cGroupBy   := ""
Local aJoin      := {}  
Local cRelation  := ""
Local aCposCalc  := {}
Local cAl5       := "" 
Local cAl6       := "" 
Local cAl7       := "" 

Private Inclui   := .F.
            
If !Pergunte("HSPM19",.T.)
 Return(.F.)
EndIf

If Empty(MV_PAR01)  
 HS_MsgInf(STR0023,STR0034,STR0001) // //"Obrigat๓rio informar o C๓digo do Procedimento"###Atencao"###"Or็amento de atendimento"
	Return(.F.)
EndIf

If Empty(MV_PAR05)
 HS_MsgInf(STR0024,STR0034,STR0001) // //"Obrigat๓rio informar a Data Final"###Atencao"###"Or็amento de atendimento"
	Return(.F.)
EndIf

FS_Filtro(@cFilM19)  //Monta o filtro

cAl5 := IIf(mv_par06 == 1, "GD", "GE")
cAl6 := cAl5 + "6"
cAl7 := cAl5 + "7"
cAl5 := cAl5 + "5"
cPf5 := cAl5 + "." + cAl5
cPf6 := cAl6 + "." + cAl6
cPf7 := cAl7 + "." + cAl7

cLstCpo    := "GCZ_REGATE/GCZ_REGGER/GCZ_NOME  /GCZ_DATATE/GCZ_NRGUIA/GCZ_NRSEQG"

cCposGrpBy := "GCZ.GCZ_FILIAL, GCZ.GCZ_REGATE, GCZ.GCZ_REGGER, GCY.GCY_NOME GCZ_NOME, GCY.GCY_DATATE GCZ_DATATE, GCZ.GCZ_NRGUIA, GCZ.GCZ_NRSEQG, "
cCposGrpBy += "SUM(" + HS_FValDes(cAl7) + ") GCZ_TOTPRO, "
cCposGrpBy += "SUM(" + HS_FValDes(cAl6) + ") GCZ_TOTTXD, "
cCposGrpBy += "SUM(CASE WHEN GBI.GBI_TIPO = '0' THEN " + HS_FValDes(cAl5) + " END) GCZ_TOTMAT, "
cCposGrpBy += "SUM(CASE WHEN GBI.GBI_TIPO = '1' THEN " + HS_FValDes(cAl5) + " END) GCZ_TOTMED "

cGroupBy   := "GCZ.GCZ_FILIAL, GCZ.GCZ_REGATE, GCZ.GCZ_REGGER, GCY.GCY_NOME, GCY.GCY_DATATE, GCZ.GCZ_NRGUIA, GCZ.GCZ_NRSEQG"

aAdd(aJoin, {     " JOIN " + RetSqlName("GCY") + " GCY"   , "" , "GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE"     , ""})
aAdd(aJoin, {" LEFT JOIN " + RetSqlName(cAl7) + " " + cAl7   , "" , cPf7+"_FILIAL = '" + xFilial(cAl7) + "' AND " + cAl7+".D_E_L_E_T_ <> '*' AND " + cPf7+"_NRSEQG = GCZ.GCZ_NRSEQG"     , ""})
aAdd(aJoin, {" LEFT JOIN " + RetSqlName(cAl6) + " " + cAl6   , "" , cPf6+"_FILIAL = '" + xFilial(cAl6) + "' AND " + cAl6+".D_E_L_E_T_ <> '*' AND " + cPf6+"_NRSEQG = GCZ.GCZ_NRSEQG"     , ""})
aAdd(aJoin, {" LEFT JOIN " + RetSqlName(cAl5) + " " + cAl5   , "" , cPf5+"_FILIAL = '" + xFilial(cAl5) + "' AND " + cAl5+".D_E_L_E_T_ <> '*' AND " + cPf5+"_NRSEQG = GCZ.GCZ_NRSEQG"     , ""})
aAdd(aJoin, {" LEFT JOIN " + RetSqlName("GBI") + " GBI"   , "" , "GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = "+ cPf5+"_CODDES"     , ""})
                             
aCposCalc := {{"GCZ_VLGUIA", STR0056, "GCZ_TOTPRO", "TMPGCZ->GCZ_TOTPRO"}, ; //"Tot. Proced."
              {"GCZ_VLGUIA", STR0057, "GCZ_TOTTXD", "TMPGCZ->GCZ_TOTTXD"}, ; //"Tot. Tax/Dia"
              {"GCZ_VLGUIA", STR0058, "GCZ_TOTMAT", "TMPGCZ->GCZ_TOTMAT"}, ; //"Tot. Materi."
              {"GCZ_VLGUIA", STR0059, "GCZ_TOTMED", "TMPGCZ->GCZ_TOTMED"}, ; //"Tot. Medica."
              {"GCZ_VLGUIA", STR0060, "GCZ_TOTGUI", "TMPGCZ->GCZ_TOTPRO + TMPGCZ->GCZ_TOTTXD + TMPGCZ->GCZ_TOTMAT + TMPGCZ->GCZ_TOTMED"}} //"Total Guia  "

nTotGuias := HS_BDados("GCZ", @aHGCZ, @aCGCZ, @nUGCZ,11, GO0->GO0_REGGER, cFilM19,,, cLstCpo,,,,,, .T.,,,, cCposGrpBy, cGroupBy,, aJoin, aCposCalc)
nGczNrSeqG := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_NRSEQG"})
nGczRegAte := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_REGATE"})
nGczTotPro := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_TOTPRO"})
nGczTotTxd := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_TOTTXD"})
nGczTotMat := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_TOTMAT"})
nGczTotMed := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_TOTMED"})
nGczTotGui := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_TOTGUI"})
              
For nForGuias := 1 To Len(aCGcz)
 vGczTotPro += aCGcz[nForGuias, nGczTotPro]
 vGczTotTxd += aCGcz[nForGuias, nGczTotTxd]
 vGczTotMat += aCGcz[nForGuias, nGczTotMat]
 vGczTotMed += aCGcz[nForGuias, nGczTotMed]
 vGczTotGui += aCGcz[nForGuias, nGczTotGui]
Next 

aSize    := MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs   := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE STR0025 FROM aSize[7], 000 To aSize[6], aSize[5] of oMainWnd // //"Selecione a guia para or็amentos"
 oGDGCZ:= MsNewGetDados():New(2, 2, aPObjs[1,3], aPObjs[1,4],0,,,,,,,,,,oDlg,aHGCZ,aCGCZ)
 oGDGCZ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 oGDGCZ:oBrowse:BlDblClick := {|| nOpcA := 1, oDlg:End()}     
 oGDGcz:AddLine(.F., .F.)
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczNrSeqG] := STR0061 //"Total "
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotPro] := vGczTotPro
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotTxd] := vGczTotTxd
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotMat] := vGczTotMat
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotMed] := vGczTotMed
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotGui] := vGczTotGui
 
 oGDGcz:AddLine(.F., .F.)
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczNrSeqG] := STR0062   //"Media "
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotPro] := vGczTotPro / nTotGuias
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotTxd] := vGczTotTxd / nTotGuias
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotMat] := vGczTotMat / nTotGuias
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotMed] := vGczTotMed / nTotGuias
 oGDGcz:aCols[Len(oGDGcz:aCols), nGczTotGui] := vGczTotGui / nTotGuias
 
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:= 1,oDlg:End()},{||nOpca:= 0,oDlg:End()})

If ( nOpcA == 0 ) 
 Return(.F.)
Endif          

// PREENCHE CAMPOS DO CABEวALHO DO ORCAMENTO
DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + oGDGcz:aCols[oGDGcz:nAt, nGczRegAte])

DbSelectArea("GCZ")
DbSetOrder(1)
DbSeek(xFilial("GCZ") + oGDGcz:aCols[oGDGcz:nAt, nGczNrSeqG])

DbSelectArea("GO0")

M->GO0_ATENDI := GCY->GCY_ATENDI
M->GO0_CODPLA := GCZ->GCZ_CODPLA
M->GO0_DESPLA := CriaVar("GO0_DESPLA")
M->GO0_CODPRO := MV_PAR01
M->GO0_DESPRO := CriaVar("GO0_DESPRO")

// PREENCHE OS DADOS DA GETDADOS DO ORCAMENTO
FS_GDados( oGDGCZ, IIF(mv_par06==1,"GD5","GE5"), @aHMM, aCMM ) 
FS_GDados( oGDGCZ, IIF(mv_par06==1,"GD6","GE6"), @aHTD, aCTD ) 
FS_GDados( oGDGCZ, IIF(mv_par06==1,"GD7","GE7"), @aHPR, aCPR ) 

//HS_ATUDESP()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	   ณ FS_FILTROณ Autor ณGilson da Silva        ณ Data ณ28/04/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Monta o Filtro para a Tabela GCZ                									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ EXPC1 = Filtro                                  									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno 	 ณ Filtro                                     														  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSPAHM19 											                                    	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Filtro(cFilM19)

Local cAlias := ""

cFilM19 := ""

If !Empty(mv_par02)
	cFilM19 := cFilM19 + " GCZ->GCZ_CODCRM = '" + mv_par02 + "' AND"
EndIf

If !Empty(mv_par03)
	cFilM19 := cFilM19 + " GCZ->GCZ_CODPLA = '" + mv_par03 + "' AND "
EndIf

cFilM19 := cFilM19 + " GCZ->GCZ_CANCEL <> '1' AND "  

If mv_par06 == 1
 cAlias := "GD7"
Else
 cAlias := "GE7"
EndIf         

cFilM19	+= " GCZ->GCZ_NRSEQG IN (SELECT G7CND->" + cAlias + "_NRSEQG FROM " + RetSqlName(cAlias) + " G7CND "
cFilM19 += " WHERE G7CND->" + cAlias + "_NRSEQG = GCZ->GCZ_NRSEQG AND"
CfILm19 += " G7CND->" + cAlias + "_DATDES BETWEEN '" + DtoS(mv_par04) + "' AND '" + DtoS(mv_par05) + "'" 
cFilM19	+= " AND G7CND->"+cAlias+"_CODDES = '" + mv_par01 + "'"
cFilM19 += ")"

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GDados บAutor  ณAlessandro Freire   บ Data ณ  05/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche aHeder e aCols do orcamento de acordo com os itensบฑฑ
ฑฑบ          ณda guia (GCZ) Selecionada                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GDados( oGDGCZ, cTabela, aHeadRet, aColRet ) 

Local nGCZNRSEQG := aScan( oGDGCZ:aHeader, {|x| X[2] == "GCZ_NRSEQG"} )
Local cPArq      := cTabela + "->" + PrefixoCpo(cTabela)
Local nForTab    := 0
Local nForAux    := 0
Local nITEM      := aScan( aHeadRet, {|x| SubStr(x[2],4) == "_ITEM  " } )

Local aHGE       := {}
Local aCGE       := {}
Local nUGE       := 0                                                 
Local cItem      := Space(len(GO5->GO5_ITEM))

// Tabela GDn ou GEn
HS_BDados(cTabela,;
          @aHGE ,;
          @aCGE ,;
          @nUGE ,;
          2     ,;
          oGDGCZ:aCols[oGDGCZ:nAt][nGCZNRSEQG],;
          cPArq+"_NRSEQG == '" + oGDGCZ:aCols[oGDGCZ:nAt][nGCZNRSEQG] + "'",,,"ALL")


For nForTab := 1 to Len(aCGE)
 If nForTab > 1
  AAdd( aColRet, Array(Len(aHeadRet)+1) )
  // Inicializa os campos
  For nForAux := 1 to Len(aHeadRet)          
   aColRet[nForTab][nForAux]       := CriaVar(aHeadRet[nForAux][2])
  Next nForAux
 EndIf
 
 cItem := Soma1(cItem, Len(aColRet[nForTab, nItem]))
 aColRet[nForTab, nItem] := cItem
 
 For nForAux := 1 to Len(aCGE[nForTab])-1
  // Posicao do campo no GO5,6 ou 7
  nPosHeadRet := aScan( aHeadRet, { |x| SubStr(x[2],4) == SubStr(aHGE[nForAux][2],4) } )
  
  If nPosHeadRet > 0             
   If aHeadRet[nPosHeadRet][10] == "V"
    aColRet[nForTab][nPosHeadRet] := CriaVar(aHeadRet[nPosHeadRet][2])
   Else
  	 aColRet[nForTab][nPosHeadRet] := aCGE[nForTab][nForAux]     
  	EndIf 
  EndIf
  
 Next nForAux
 aColRet[nForTab][Len(aColRet[nForTab])] := .f.
Next nForTab

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VlExcGDบAutor  ณCibele Peria        บ Data ณ  19/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os valores sumarizados das despesas no cabecalho  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VlExcGD(cTipo)

 If cTipo == "P"
  If oGDPR:aCols[oGDPR:nAt, nUPR+1]
   M->GO0_VALPRO := M->GO0_VALPRO - HS_CValDes("GO7",,, oGDPR)
  Else
   M->GO0_VALPRO := M->GO0_VALPRO + HS_CValDes("GO7",,, oGDPR)
  Endif    
 ElseIf cTipo == "M"
  If Posicione("GBI", 1, xFilial("GBI")+oGDMM:aCols[oGDMM:nAt, nMMCODDES],"GBI_TIPO") == "0"
   If oGDMM:aCols[oGDMM:nAt, nUMM+1]
    M->GO0_VALMAT := M->GO0_VALMAT - HS_CValDes("GO5",,, oGDMM)
   Else
    M->GO0_VALMAT := M->GO0_VALMAT + HS_CValDes("GO5",,, oGDMM)
   Endif
  Else
   If oGDMM:aCols[oGDMM:nAt, nUMM+1]  
    M->GO0_VALMED := M->GO0_VALMED - HS_CValDes("GO5",,, oGDMM)
   Else
    M->GO0_VALMED := M->GO0_VALMED + HS_CValDes("GO5",,, oGDMM)
   Endif    
  Endif
 ElseIf cTipo == "T"
  If oGDTD:aCols[oGDTD:nAt, nUTD+1]   
   M->GO0_VALTXD := M->GO0_VALTXD - HS_CValDes("GO6",,, oGDTD)
  Else 
   M->GO0_VALTXD := M->GO0_VALTXD + HS_CValDes("GO6",,, oGDTD)
  Endif 
 Endif
 
 M->GO0_VALTOT := M->GO0_VALPRO + M->GO0_VALMAT + M->GO0_VALMED + M->GO0_VALTXD
 
 oEnchoice:Refresh()
  
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_AQtM19 บAutor  ณCibele Peria        บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apos alteracao na quantidade de uma despesa, recalcula os  บฑฑ
ฑฑบ          ณ valores totais do orcamento                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_AQtM19(cAlias)
 Local aArea := GetArea()
 If FunName() <> "HSPAHM19"
  Return(.T.)
 Endif
 
 If ReadVar() == "M->GO5_QTDDES" .and. oGDMM:aCols[oGDMM:nAt, nMMValDes] > 0
  M->GO0_VALMAT := Criavar("GO0_VALMAT")
  M->GO0_VALMED := Criavar("GO0_VALMED")  
 
  FS_TOTDESP(oGDMM,"" , "GO5", nMMQtdDes, .T., M->GO5_QTDDES, oGDMM:nAt)
 
 ElseIf ReadVar() == "M->GO6_QTDDES" .and. oGDTD:aCols[oGDTD:nAt, nTDValDes] > 0
	 M->GO0_VALTXD := Criavar("GO0_VALTXD")
	
	 FS_TOTDESP(oGDTD, "GO0_VALTXD", "GO6", nTDQtdDes, .T., M->GO6_QTDDES, oGDTD:nAt)
   
 ElseIf ReadVar() == "M->GO7_QTDDES" .and. oGDPR:aCols[oGDPR:nAt, nPRValDes] > 0
 	M->GO0_VALPRO := Criavar("GO0_VALPRO") 
	
	 FS_TOTDESP(oGDPR, "GO0_VALPRO", "GO7", nPRQtdDes, .T., M->GO7_QTDDES, oGDPR:nAt)
 Endif
  
 M->GO0_VALTOT := M->GO0_VALMAT + M->GO0_VALMED + M->GO0_VALTXD + M->GO0_VALPRO
 oEnchoice:Refresh() 
 RestArea(aArea)  
Return(.T.)         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RevalorบAutor  ณCibele Peria        บ Data ณ  20/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Revalorizacao de um item de despesa                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Revalor(cAliasDes, nPosDes,cCodPla, cCodDes, dDatDes, cCodLoc, cCodAto, aAtendi)
 Local cAliasOld := Alias()
 Local aROld     := {}
 Local nRDes     := 0
 Local lRet      := .T.

 If cAliasDes == "GO5"
  aROld := aClone(__aRMatMed)
  For nRDes := 1 To Len(__aRMatMed)
   __aRMatMed[nRDes, 1] := StrTran(__aRMatMed[nRDes, 1], "oGDMM:nAt", AllTrim(Str(nPosDes))) 
  Next 
  lRet := HS_VMatMed(cCodPla, cCodDes, , , , , ,dDatDes,cCodLoc)
 
  __aRMatMed := aClone(aROld)
  
 ElseIf cAliasDes == "GO6"
  aROld := aClone(__aRTaxDia)
  For nRDes := 1 To Len(__aRTaxDia)
   __aRTaxDia[nRDes, 1] := StrTran(__aRTaxDia[nRDes, 1], "oGDTD:nAt", AllTrim(Str(nPosDes))) 
  Next
  lRet := HS_VldTaxD(cCodPla, cCodLoc, cCodDes, , , , dDatDes)
   
  __aRTaxDia := aClone(aROld)  

 ElseIf cAliasDes == "GO7"
  aROld := aClone(__aRProced)
  For nRDes := 1 To Len(__aRProced)
   __aRProced[nRDes, 1] := StrTran(__aRProced[nRDes, 1], "oGDPR:nAt", AllTrim(Str(nPosDes))) 
  Next
  lRet := HS_VProHon(cCodPla, cCodLoc, cCodDes, , , ,"0" , , cCodAto, aAtendi, , dDatDes)[1]
    
  __aRProced := aClone(aROld)
      
 Endif 
  
 oGDMM:oBrowse:Refresh()
 oGDTD:oBrowse:Refresh()
 oGDPR:oBrowse:Refresh()
 
 DbSelectArea(cAliasOld)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RejM19 บAutor  ณCibele Peria        บ Data ณ  20/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rejeicao de um orcamento aberto                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_RejM19()
 Local aAreaOld := GetArea() 
 
 If M->GO0_STATUS == "2"
  HS_MsgInf(STR0043,STR0034,STR0063) //"Este orcamento ja se encontra rejeitado"###Atencao" //"Rejeicao de um orcamento aberto"
 ElseIf M->GO0_STATUS == "1"
  HS_MsgInf(STR0044,STR0034,STR0063) //"Este orcamento esta confirmado e nao pode ser rejeitado"###Atencao"###"Or็amento de atendimento" //"Rejeicao de um orcamento aberto"
 Else
  DbSelectArea("GO0")
  DbSetOrder(1)
  DbSeek(xFilial("GO0") + M->GO0_NUMORC)
  Reclock("GO0", .F.) 
   GO0->GO0_STATUS = "2" //Rejeitado
   GO0->GO0_CDREJE = M->GO0_CDREJE 
  MsUnlock()
 Endif 
 
 RestArea(aAreaOld) 
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LegM19 บAutor  ณCibele Peria        บ Data ณ  20/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_LegM19()
 BrwLegenda(cCadastro, STR0009, {{"BR_AMARELO"   , STR0046}, ; //"Legenda"###"Aberto"
                                 {"BR_VERDE" , STR0047}, ; //"Confirmado"
                                 {"BR_VERMELHO", STR0048}})  //"Rejeitado"
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_FilM19 บAutor  ณCibele Peria        บ Data ณ  25/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtro do browse pelo status do orcamento                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar orcamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FilM19(lSetFilter)
 Local lRet     := .F. 
 Local oObjMBrw := IIf(lSetFilter, GetObjBrow(), Nil)
                                    
 cFltM19  := "GO0_FILIAL = '" + xFilial("GO0") + "' "   

 If (lRet := Pergunte("HFLM19"))
  If mv_par01 == 1
   cFltM19 += " AND GO0_STATUS = '0'"
  ElseIf mv_par01 == 2
   cFltM19 += " AND GO0_STATUS = '1'"
  ElseIf mv_par01 == 3
   cFltM19 += " AND GO0_STATUS = '2'"
  Endif
  
  If lSetFilter 
   SetMBTopFilter("GO0", cFltM19)
   oObjMBrw:GoTop()
   oObjMBrw:Refresh()
  EndIf
 EndIf                                                                  
  
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DocsOrcบAutor  ณDaniel Peixoto      บ Data ณ  22/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao dos relatorios da capa do or็amento,             บฑฑ
ฑฑบ          ณ descritivo do or็amento ou ambos                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_DocsOrc(nOpcDoc)
 Local aArea := GetArea()
 
 If nOpcDoc == 1 .Or. nOpcDoc == 3  //Capa Or็amento
  HSPAHRA3(GO0->GO0_NUMORC)
 EndIf
 
 If nOpcDoc == 2 .Or. nOpcDoc == 3 //Descritivo or็amento
  HSPAHRA8(GO0->GO0_NUMORC)
 EndIf
 
 RestArea(aArea)
Return()

Static Function FS_VldRej()
 Local lRet := .T.

 If !(lRet := !EMPTY(M->GO0_CDREJE))
  HS_MsgInf(STR0075, STR0066, STR0076) //"Campo C๓digo da Rejei็ใo em branco"###"Atencao"###"Rejeitar Or็amento"
 EndIf

Return(lRet)               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ATUDESPบAutor  ณMario Arizono       บ Data ณ  19/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualizacao totais de mat/med, tax/diarias, procedimentos  บฑฑ
ฑฑบ          ณ e total geral                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Evento cfieldok                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ATUDESP()
 Local aArea   := GetArea()
 
 
 M->GO0_VALMAT := Criavar("GO0_VALMAT")
 M->GO0_VALMED := Criavar("GO0_VALMED")  
 M->GO0_VALTXD := Criavar("GO0_VALTXD")
 M->GO0_VALPRO := Criavar("GO0_VALPRO")
  
 
  FS_TOTDESP(oGDMM,"" , "GO5", nMMQtdDes)
  FS_TOTDESP(oGDTD, "GO0_VALTXD", "GO6", nTDQtdDes)
  FS_TOTDESP(oGDPR, "GO0_VALPRO", "GO7", nPRQtdDes)
 
  
 M->GO0_VALTOT := M->GO0_VALMAT + M->GO0_VALMED + M->GO0_VALTXD + M->GO0_VALPRO
 oEnchoice:Refresh() 
   
 RestArea(aArea)
Return(.T.)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TOTDESPบAutor  ณMario Arizono       บ Data ณ  18/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorno dos totais de mat/med, tax/diarias e procedimentos บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Validacao orcamento                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TOTDESP(oDesp, cNomCpo, cAlias, nPosQtd, lQtdAten, nQtdMemo, nPosQtdAtu)
 Local aArea   := GetArea()
 Local nPosDes := 0
 Local nValdes := 0
                      
 Default   lQtdAten := .F. 
 Default   nPosQtd  := 0   
 Default nPosQtdAtu := 0
 Default   nQtdMemo := 0   
 
 For nPosDes := 1 to len(oDesp:aCols)
  If !(oDesp:aCols[nPosDes, len(oDesp:aCols[nPosDes])])
   nValDes := (HS_CValDes(cAlias,,, oDesp,.T.,,nPosDes) * IIF(lQtdAten .And. nPosQtdAtu == nPosDes, nQtdMemo, oDesp:aCols[nPosDes, nPosQtd]))   
   
   If cAlias == "GO5"
    If Posicione("GBI", 1, xFilial("GBI")+ oDesp:aCols[nPosDes, nMMCodDes],"GBI_TIPO") == "0"
     cNomCpo := "GO0_VALMAT"
    Else 
     cNomcpo := "GO0_VALMED"
    Endif 
   Endif 
   &("M->" + cNomCpo) := &("M->" + cNomCpo) + nValDes    
  Endif
  Next nPosDes
     
 RestArea(aArea)
Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDOK  บAutor  ณMario Arizono       บ Data ณ  15/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao dos itens com valor zerado                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Validacao ok orcamento                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldOk()
 Local aArea   := GetArea()
 Local nPosDes := 0
 Local lRet    := .T.
 Local cInfPro := ""

   
 For nPosDes := 1 to len(oGDMM:aCols)
  If !Empty(oGDMM:aCols[nPosDes, nMMCodDes]) .And. oGDMM:aCols[nPosDes, nMMValDes] == 0 .And. !(oGDMM:aCols[nPosDes, nUMM + 1])
   cInfPro += ALLTRIM(oGDMM:aCols[nPosDes, nMMCodDes]) + IIF(nPosDes < len(oGDMM:aCols), "/", IIF(len(oGDTD:aCols) > 0 .Or. len(oGDPR:aCols) > 0, "/", ""))  
  Endif   
 Next nPosDes
 
 For nPosDes := 1 to len(oGDTD:aCols)
  If !Empty(oGDTD:aCols[nPosDes, nTDCodDes]) .And. oGDTD:aCols[nPosDes, nTDValDes] == 0 .And. !(oGDTD:aCols[nPosDes, nUTD + 1])
   cInfPro += ALLTRIM(oGDTD:aCols[nPosDes, nTDCodDes]) + IIF(nPosDes < len(oGDTD:aCols), "/", IIF(len(oGDPR:aCols) > 0, "/", ""))  
  Endif   
 Next nPosDes
 
  For nPosDes := 1 to len(oGDPR:aCols)
  If !Empty(oGDPR:aCols[nPosDes, nPRCodDes]) .And. oGDPR:aCols[nPosDes, nPRValDes] == 0 .And. !(oGDPR:aCols[nPosDes, nUPR + 1])
   cInfPro += ALLTRIM(oGDPR:aCols[nPosDes, nPRCodDes]) + IIF(nPosDes < len(oGDPR:aCols), "/", "")  
  Endif   
 Next nPosDes 
 
 If !Empty(cInfPro)   
  cInfPro := IIF(SUBSTR(cInfPro,len(cInfPro),1) == "/", SUBSTR(cInfPro,1, len(cInfPro)-1), cInfPro )
  HS_MsgInf(STR0079 + cInfPro + STR0080, STR0066, STR0081) //"Verifique a(s) despesa(s) ["##"] com valor zerado."##"Valida็ใo itens or็camento"
  lRet := .F.
 Endif 
 
 RestArea(aArea)
Return(lRet)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 10/06/07 ณฑฑ
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
Local aRot1   := {{STR0064,"HS_DocsOrc(1)", 0, 2},;  //"Capa or็amento"
                  {STR0065,"HS_DocsOrc(2)", 0, 2}} //"Descritivo Or็am"
 
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 01, 0, nil},; 		//"Pesquisar"
                  {OemtoAnsi(STR0003), "HS_MntM19", 0, 02, 0, nil},; 		//"Visualizar"
                  {OemtoAnsi(STR0004), "HS_MntM19", 0, 03, 0, nil},; 		//"Incluir"
                  {OemtoAnsi(STR0005), "HS_MntM19", 0, 04, 0, nil},; 		//"Alterar"
                  {OemtoAnsi(STR0006), "HS_MntM19", 0, 05, 0, nil},; 		//"Excluir"
                  {OemtoAnsi(STR0007), "HS_MntM19", 0, 03, 0, nil},; 		//"Copiar"
                  {OemtoAnsi(STR0008), "HS_MntM19", 0, 03, 0, nil},; 		//"Gerar"
                  {OemtoAnsi(STR0042), "HS_MntM19", 0, 04, 0, nil},; 		//"Rejeitar"
                  {OemtoAnsi(STR0009), "HS_LegM19", 0, 02, 0, nil},;   //"Legenda"
                  {OemToAnsi(STR0077), aRot1      , 0, 04, 0, nil}} 	  //"Doctos"
Return(aRotina)