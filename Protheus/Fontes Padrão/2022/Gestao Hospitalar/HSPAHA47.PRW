#INCLUDE "HSPAHA47.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ HSPAHA47 ณ Autor ณ Eduardo Alves         ณ Data ณ 21/06/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cadastro de Questionario Anamnese                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Gestao Hospitalar                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHA47()

Local aCampos := {{"C", "GFS_TAHINT"}}
Local cFilA47 := ""
Local bKeyF12 := SetKey(VK_F12, {|| FS_FilA47(.T., @cFilA47)})
	
Private aRotina :=	MenuDef()
Private cCadastro := OemToAnsi(STR0006) //"Questionแrio Anamnese"
	
 If !HS_ExisDic(aCampos)
	 Return(.F.)
	EndIf
 
	DbSelectArea("GFS")
	DbSetOrder(1)

 If FS_FilA47(.F., @cFilA47) 
  mBrowse(06, 01, 22, 75, "GFS",,,,,,,,,,,,,, cFilA47)
 Endif 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A47    บAutor  ณEduardo Alves       บ Data ณ  21/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณ Funcao de Tratamento do Cadastro Questionแrio Anamnese     ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MntA47(cAliasA47, nRegA47, nOpcA47)

Local oDlgQue, oFolder, nOpcDlg	:= ""
Local nGDOpc 	:= IIf(Str(aRotina[nOpcA47, 4], 1) $ "3", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local nGDOpcGHP := IIf(Str(aRotina[nOpcA47, 4], 1) $ "3/4", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local nLenGD 	:= 0
Local aHGft := {}, aCGft := {}, nUGft := 0, nLGGR := 0, aHGGR := {}, aCGGR := {}, nUGGR := 0
Local aHGHP := {}, aCGHP := {}, nUGHP := 0
Local nLGHP := 0
Local oEnGfs, cOrderBy := ""
Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local aCposAlt := {}

Private aTela := {}, aGets := {}, oGGR, oGDGft
Private nGGRCODPRO := 0, nGGRCDITEM := 0, nGftSqGrQu := 0, nGHPCodFun := 0


/* Nใo permiti a exclusao dos dados de um questionแrio (GFS), se o mesmo ja foi utilizado em alguma anamnese */
If aRotina[nOpcA47, 4] == 5 .And. HS_CountTB("GFU", "GFU_CDQUES = '" + GFS->GFS_CDQUES + "'") > 0
	HS_MsgInf(STR0008, STR0007, STR0009) //"Exclusใo nใo permitida, pois este questionแrio estแ relacionado เ Anamnese."###"Aten็ใo"###"Exclusใo"
	Return(.F.)
EndIf

If nOpcA47 == 4
	DbSelectArea("SX3")
	DbSetOrder(1) //X3_ARQUIVO + X3_ORDEM
	DbSeek("GFS")
	While !Eof() .And. SX3->X3_ARQUIVO == "GFS"
		If !(SX3->X3_CAMPO $ "GFS_CODCRM/GFS_CODESP/GFS_TIPPRO/GFS_FUNCAO/GFS_TPQUES/GFS_CODLOC")
			aAdd(aCposAlt, SX3->X3_CAMPO)
		EndIf
		DbSkip()
	End
Else
	aCposAlt := {"GFS_CODCRM", "GFS_CODESP", "GFS_TIPPRO", "GFS_FUNCAO", "GFS_TPQUES", "GFS_CDQUES", "GFS_IDATIV", "GFS_DSQUES", "GFS_CODCRM", "GFS_SWHINT", "GFS_TAHINT", "GFS_FFICHA", "GFS_MODIMP", "GFS_CODLOC"}
EndIf

RegToMemory("GFS", (aRotina[nOpcA47, 4] == 3))

nLenGD := HS_BDados("GFT", @aHGft, @aCGft, @nUGft, 2,, IIf((aRotina[nOpcA47, 4] == 3), Nil, "GFT_CDQUES = '" + M->GFS_CDQUES + "'"),,,,,,,,,,,,,,,,,,"GFT_SQGRQU")
nGftSqGrQu := aScan(aHGft, {| aVet | aVet[2] == "GFT_SQGRQU"})
nGftGrpPer := aScan(aHGft, {| aVet | aVet[2] == "GFT_GRPPER"})


If (nLenGD == 0)
	aCGft[1, nGftSqGrQu] := Soma1(aCGft[1, nGftSqGrQu], Len(aCGft[1, nGftSqGrQu]))
EndIf

cOrderBy :="GGR_CDITEM"
cLstCpo := "GGR_CODPRO/GGR_DESPRO/GGR_CDITEM/GGR_CODCRM/GGR_NOMCRM"

nLGGR := HS_BDados("GGR", @aHGGR, @aCGGR, @nUGGR, 1, , IIF(aRotina[nOpcA47, 4] # 3, "GGR->GGR_CDQUES == '" + M->GFS_CDQUES + "'", Nil),,,cLstCpo,,,,,,.T.,,,.T.,,,,,,cOrderBy)
nGGRCODPRO := aScan(aHGGR, {| aVet | aVet[2] == "GGR_CODPRO"})
nGGRCDITEM := aScan(aHGGR, {| aVet | aVet[2] == "GGR_CDITEM"})

If Empty(aCGGR[1, nGGRCDITEM])
	aCGGR[1, nGGRCDITEM] := StrZero(1, Len(GGR->GGR_CDITEM))
EndIf

nLGHP := HS_BDados("GHP", @aHGHP, @aCGHP, @nUGHP, 1,, IIf(aRotina[nOpcA47, 4] # 3, "GHP_CDQUES = '" + M->GFS_CDQUES + "'", Nil))
nGHPCodFun := aScan(aHGHP, {| aVet | aVet[2] == "GHP_CODFUN"})
nGHPItem   := aScan(aHGHP, {| aVet | aVet[2] == "GHP_ITEM  "})

If (nLGHP == 0)
	aCGHP[1, nGHPItem] := StrZero(1, Len(GHP->GHP_ITEM))
EndIf

aSize 			:= MsAdvSize(.T.)
aObjects := {}

aAdd(aObjects, {100, 040, .T., .T.})
AAdd(aObjects, {100, 060, .T., .T., .T.})

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

// Folder - GetDados
aObjects := {}
aAdd(aObjects, {100, 100, .T., .T.})

aInfo := {aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0}
aPGDs := MsObjSize(aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlgQue TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Questionแrio Anamnese"

oEnGfs := MsMGet():New("GFS", nRegA47, nOpcA47,,,,, aPObjs[1], aCposAlt,,,,, oDlgQue)
oEnGfs :oBox:align:= CONTROL_ALIGN_TOP

@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Of oDlgQue PROMPTS STR0019, STR0020, STR0021 PIXEL //"Grupo Perguntas"###"Procedimentos"###"Fun็๕es Anamnese"

oGDGft := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,, "+GFT_SQGRQU",,, 99999,,,, oFolder:aDialogs[1], aHGft, aCGft)
oGDGft:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGGR := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGGR:oBrowse:nAt, oGGR:aCols, {nGGRCODPRO})",, "+GGR_CDITEM",,,,,,, oFolder:aDialogs[2], aHGGR, aCGGR)
oGGR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGHP := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpcGHP, "HS_DuplAC(oGGR:oBrowse:nAt, oGGR:aCols, {nGHPCODFUN})",, "+GHP_ITEM",,,,,,, oFolder:aDialogs[3], aHGHP, aCGHP)
oGHP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgQue ON INIT EnchoiceBar (oDlgQue,	{|| nOpcDlg := 1, IIF(Obrigatorio(aGets, aTela) .And. FS_VldOK(oGDGft), oDlgQue:End(), nOpcDlg := 0)}, ;
{|| nOpcDlg := 0, oDlgQue:End()})

If (nOpcDlg == 1)
	Begin Transaction
	If (aRotina[nOpcA47, 4] <> 2)
		FS_GrvA47(Str(aRotina[nOpcA47, 4], 1))
	ElseIf nOpcA47 == 5
		FS_GrvCop(GFS->GFS_CDQUES)
	EndIf
	End Transaction
	
	While __lSx8
		ConfirmSx8()
	End
Else
	While __lSx8
		RollBackSxe()
	End
EndIf
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA47 บAutor  ณEduardo Alves       บ Data ณ  21/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณFuncao de Gravacao ou Exclusao dos Dados    															 ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvA47(cOpcGrv)

 If cOpcGrv $ "3/4" // Inclusใo ou Alteracao
  
  DbSelectArea("GFS")
  DbSetOrder(1)
 
  If cOpcGrv == "3"
   M->GFS_CDQUES := HS_VSxeNum("GFS", "M->GFS_CDQUES", 1)
   ConfirmSx8()
  Else
   DbSeek(xFilial("GFS") + M->GFS_CDQUES)
  EndIf
				
  RecLock("GFS", cOpcGrv == "3")
   HS_GrvCpo("GFS")
  MsUnLock()
  
  FS_GrvGD("GFT", 1, oGDGFT:aCols, oGDGFT:aHeader, nGftSqGrQu, nGftGrpPer)
  FS_GrvGD("GGR", 1, oGGR:aCols, oGGR:aHeader, nGGRCDITEM, nGGRCODPRO)
  FS_GrvGD("GHP", 1, oGHP:aCols, oGHP:aHeader, nGHPITEM, nGHPCODFUN)
 
 Else 
  
  FS_DelGD("GFT", 1, oGDGFT:aCols, nGftSqGrQu)
  FS_DelGD("GGR", 1, oGGR:aCols, nGGRCDITEM)
  FS_DelGD("GHP", 1, oGHP:aCols, nGHPITEM)
  
		DbSelectArea("GFS")
		RecLock("GFS", .F., .T.)
		 DbDelete()
		MsUnlock()
		WriteSx2("GFS")

 Endif
 
Return(.T.) 

Static Function FS_DelGD(cAlias, nOrdem, aCols, nItem)

 Local nForGrv := 0

 DbSelectArea(cAlias)
 DBSetOrder(nOrdem)
 For nForGrv := 1 To Len(aCols)   
  If DbSeek(xFilial(cAlias) + M->GFS_CDQUES + aCols[nForGrv, nItem])
	  RecLock(cAlias, .F., .F.)
    DbDelete()
   MsUnlock()
   WriteSx2(cAlias)
  EndIf	  
 Next   
 
Return()

Static Function FS_GrvGD(cAlias, nOrdem, aCols, aHeader, nItem, nPrincipal)

 Local nForGrv := 0, lFound := .F.
 Local cPrefixo := "M->" + PrefixoCpo(cAlias)
 Local cPrefCpo := cAlias + "->" + PrefixoCpo(cAlias)

 DbSelectArea(cAlias)
 DBSetOrder(nOrdem)
 For nForGrv := 1 To Len(aCols)   
  
  If cAlias == "GGR"
   lFound := DbSeek(xFilial(cAlias) + aCols[nForGrv, nGGRCODPRO] + aCols[nForGrv, nItem])
  Else   
   lFound := DbSeek(xFilial(cAlias) + M->GFS_CDQUES + aCols[nForGrv, nItem])
  EndIf
                   
  If !(aCols[nForGrv, Len(aHeader) + 1]) .And. !Empty(aCols[nForGrv, nPrincipal])
   RecLock(cAlias, IIf(lFound, .F., .T.))
   		HS_GrvCpo(cAlias, aCols, aHeader, nForGrv) 
   		&(cPrefCpo + "_FILIAL") := xFilial(cAlias)
   		 Iif(cAlias == "GGR" .And. lFound ,"",&(cPrefCpo + "_CDQUES") := M->GFS_CDQUES)
   MsUnlock()
   
  ElseIf lFound
   RecLock(cAlias, .F., .F.)
    DbDelete()
   MsUnlock()
   WriteSx2(cAlias)   
  EndIf  
 Next
 
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldOK  บAutor  ณEduardo Alves       บ Data ณ  21/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados no Botao OK.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldOk(oGDVld)

	Local lRet  := .T.	
	Local nFor  := 0  
	Local nCont := 0
	
 For nFor := 1 To Len(oGDVld:aCols) 
  If !Empty(oGDVld:aCols[nFor, nGGRCODPRO])
   nCont++
  EndIf 
 Next 

 lRet := oGDVld:TudoOk()
 
 If lRet .And. nCont == 0
  HS_MsgInf(STR0012, STR0007, STR0011) //"Nenhum Grupo de Perguntas cadastrado para este questionแrio."###"Aten็ใo"###"Confirma็ใo dos Dados"
  lRet := .F.
 EndIf 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FilA47 บAutor  ณEduardo Alves       บ Data ณ  21/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtro da MBrowse                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FilA47(lSetFilter, cFilA47)
 Local oObjMBrw, lRet := .T.
 
 Default lSetFilter := .T.
 
 oObjMBrw := IIf(lSetFilter, GetObjBrow(), Nil) 

 If ( lRet := Pergunte("HSPA47",.T.) )
  cFilA47 := "    GFS_FILIAL = '" + xFilial("GFS") + "' "
  cFilA47 += "AND GFS_CODCRM >= '" + MV_PAR01 + "' AND GFS_CODCRM <= '" + MV_PAR02 + "' "
  cFilA47 += "AND GFS_CODESP >= '" + MV_PAR03 + "' AND GFS_CODESP <= '" + MV_PAR04 + "' "
 Endif

 If lSetFilter .And. lRet
 	MsgRun(STR0013, STR0014, {|| SetMBTopFilter("GFS", cFilA47), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando os questionแrios..."###"Sele็ใo de registros"
 EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA47 บAutor  ณEduardo Alves       บ Data ณ  21/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do campos                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldA47()
	Local aArea 	:= GetArea()
	Local lRet 		:= .T.
	Local cCampo := ReadVar()
	
	/* Medico */
	If cCampo == "M->GFS_CODCRM"
		If !(lRet := IIf(!Empty(M->GFS_CODCRM), HS_SeekRet("SRA", "M->GFS_CODCRM", 11, .F., "M->GFS_NOMCRM", "RA_NOME",,, .T.), .T.))
			HS_MsgInf(STR0015, STR0007, STR0010) //"CRM do profissional nใo encontrado."###"Aten็ใo"###"Valida็ใo dos Campos"
		EndIf

	/* Especialidade */
	ElseIf cCampo == "M->GFS_CODESP"
		If !(lRet := IIf(!Empty(M->GFS_CODESP), HS_SeekRet("GFR","M->GFS_CODESP",1,.F.,"M->GFS_NOMESP","GFR_DSESPE",,,.T.), .T.))
			HS_MsgInf(STR0016, STR0007, STR0010) //"Especialidade nใo encontrada."###"Aten็ใo"###"Valida็ใo dos Campos"
	 EndIf

	/* Tipo de Profissional */
	ElseIf cCampo == "M->GFS_TIPPRO"
		lRet := Empty(M->GFS_TIPPRO) .Or. Pertence("0123456")

	/* Grupo de Perguntas */
	ElseIf cCampo == "M->GFT_GRPPER"
	 If !(lRet := IIf(!Empty(M->GFT_GRPPER), HS_SeekRet("GCO","M->GFT_GRPPER", 1, .F., "GFT_DGRPPE", "GCO_DGRPPE",,, .T.), .T.))
			HS_MsgInf(STR0017, STR0007, STR0010) //"Grupo de Pergunta nใo encontrado."###"Aten็ใo"###"Valida็ใo dos Campos"
		EndIf
		
	ElseIf cCampo == "M->GHP_CODFUN"
	 If !(lRet := HS_SeekRet("GHN","M->GHP_CODFUN", 1, .F., "GHP_DESFUN", "GHN_DESFUN",,, .T.) )
			HS_MsgInf(STR0022, STR0007, STR0010) //"Fun็ใo nใo encontrada"###"Aten็ใo"###"Valida็ใo dos Campos"
		EndIf
	
	EndIf
 
	RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvCop บAutor  ณPatricia Queiroz    บ Data ณ  05/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo da c๓pia dos dados do questionแrio.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvCop(cCodigo)
 
 Local aArea := GetArea()
 Local nFor  := 0
 
 DbSelectArea("GFS")
 DbSetOrder(1) //GFS_FILIAL + GFS_CDQUES
 If DbSeek(xFilial("GFS") + cCodigo)
  RecLock("GFS", .T.)   
   HS_GrvCpo("GFS")
   GFS->GFS_FILIAL := xFilial("GFS")
   GFS->GFS_CDQUES := GETSXENUM("GFS","GFS_CDQUES",, 1)
  MsUnLock()
 EndIf
 
 DbSelectArea("GFT")
 DbSetOrder(1) //GFT_FILIAL + GFT_CDQUES + GFT_SQGRQU
 If DbSeek(xFilial("GFT") + cCodigo) 
  For nFor := 1 To Len(oGDGFT:aCols)
   RecLock("GFT", .T.)
    HS_GrvCpo("GFT", oGDGFT:aCols, oGDGFT:aHeader, nFor)
    GFT->GFT_FILIAL := xFilial("GFT")
    GFT->GFT_CDQUES := GFS->GFS_CDQUES
   MsUnLock() 
  Next   
  
  For nFor := 1 To Len(oGGR:aCols)
  	If !Empty(oGGR:aCols[1][2])
   RecLock("GGR", .T.)
    HS_GrvCpo("GGR", oGGR:aCols, oGGR:aHeader, nFor)
    GGR->GGR_FILIAL := xFilial("GGR")
    GGR->GGR_CDQUES := GFS->GFS_CDQUES
   MsUnLock() 
   EndIf
  Next   
  
  For nFor := 1 To Len(oGHP:aCols)
  	If !Empty(oGHP:aCols[1][2])
   		RecLock("GHP", .T.)
    	HS_GrvCpo("GHP", oGHP:aCols, oGHP:aHeader, nFor)
    	GHP->GHP_FILIAL := xFilial("GHP")
    	GHP->GHP_CDQUES := GFS->GFS_CDQUES
   		MsUnLock() 
   EndIf
  Next
  
 EndIf

 RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
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
Local aRotina :=	{{OemToAnsi(STR0001), "AxPesqui" , 0, 1, 0, nil},;	//"Pesquisar"
					 {OemToAnsi(STR0002), "HS_MntA47",	0, 2, 0, nil},;	//"Visualizar"
					 {OemToAnsi(STR0003), "HS_MntA47",	0, 3, 0, nil},;	//"Incluir"
					 {OemToAnsi(STR0004), "HS_MntA47",	0, 4, 0, nil},;	//"Alterar"
 					 {OemToAnsi(STR0018), "HS_MntA47",	0, 2, 0, nil},;	//"Copiar"																					
					 {OemToAnsi(STR0005), "HS_MntA47",	0, 5, 0, nil}}	//"Excluir"
 
Return(aRotina)
