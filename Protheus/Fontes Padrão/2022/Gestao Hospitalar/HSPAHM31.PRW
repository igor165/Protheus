#INCLUDE "HSPAHM31.ch"
#include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM31  º Autor ³ Marcelo Jose       º Data ³  26/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MOVIMENTACAO DO CCIH                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM31()
Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM31(.T.)})

Private aRotina    := {}, cCadastro := STR0001 //"MOVIMENTACAO DO C.C.I.H."
Private cFilM31    := ""

aRotina := MenuDef()

DbSelectArea("GCY")
DbSetOrder(1)

If FS_FilM31(.F.)
	mBrowse(06, 01, 22, 75, "GCY",,,,,,,,,,,,,, cFilM31)
EndIf

SetKey(VK_F12, bKeyF12)
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±     NOTIFICACAO            AUTOR: MARCELO JOSE      DATA: 26/04/2005    ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION HS_Notifi(cAliasM31, nRegM31, nOpcM31)
Local nCtafor, nOpcA := 0, oEnGcy, nGDOpc := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlg , oFolder1 , oFolder2, nGehGe := 0 , nGehGp := 0, nGepGe := 0
Local aCposGcy := {"GCY_DATATE","GCY_REGGER","GCY_REGATE","GCY_NOME","GCY_SEXO","GCY_DATALT","GCY_TPALTA","GCY_DESALT","GCY_DTNASC","GCY_ORIPAC","GCY_DORIPAC","GCY_CIDINT","GCY_DCIDIN","GCY_OBTINF"}
Local aCposAlt := {"GCY_CIDINT","GCY_OBTINF"}

Private nAtGeh := 1, nAtGep := 1, cGehSitPri := ""
Private aGehGe := {}, aGepGe := {}
Private aCGEH 	:= {}, aHGEH  := {}, nUGEH := 0, nLGEH := 0, oGEH
Private aCGEI 	:= {}, aHGEI  := {}, nUGEI := 0, nLGEI := 0, oGEI
Private aCGEJ 	:= {}, aHGEJ  := {}, nUGEJ := 0, nLGEJ := 0, oGEJ
Private aCGEO 	:= {}, aHGEO  := {}, nUGEO := 0, nLGEO := 0, oGEO
Private aCGEP 	:= {}, aHGEP  := {}, nUGEP := 0, nLGEP := 0, oGEP
Private aCGEQ 	:= {}, aHGEQ  := {}, nUGEQ := 0, nLGEQ := 0, oGEQ

RegToMemory("GCY", .F.)

/* RELACIONAMENTO FATORES DE RISCO */
HS_BDados("GEO", @aHGEO, @aCGEO, @nUGEO, 2, M->GCY_REGATE, IIf(nOpcM31 # 3, "GEO->GEO_REGATE == '" + M->GCY_REGATE + "'", Nil),,,,,,.T.)
nGeoSeqGeo := aScan(aHGEO, {| aVet | aVet[2] == "GEO_SEQGEO"})

/* RELACIONAMENTO DADOS DA INFECCAO */
HS_BDados("GEH", @aHGEH, @aCGEH, @nUGEH, 2, M->GCY_REGATE, IIf(nOpcM31 # 3, "GEH->GEH_REGATE == '" + M->GCY_REGATE + "'", Nil),,,,,,.T.)
nGehSeqGeh := aScan(aHGEH, {| aVet | aVet[2] == "GEH_SEQGEH"})
nGehSitPri := aScan(aHGEH, {| aVet | aVet[2] == "GEH_SITPRI"})
nGehSitEsp := aScan(aHGEH, {| aVet | aVet[2] == "GEH_SITESP"})
nGehNomEsp := aScan(aHGEH, {| aVet | aVet[2] == "GEH_DESESP"})

For nGehGe := 1 To Len(aCGEH)
	aHGei := {}; aCGei := {}; nUGei := 0
	aHGej := {}; aCGej := {}; nUGej := 0
	aCGEP	:= {}; aHGEP := {}; nUGEP := 0
	
	/* RELACIONAMENTO PROCEDIMENTOS DE RISCO */
	HS_BDados("GEI", @aHGEI, @aCGEI, @nUGEI, 2, aCGEH[nGehGe, nGehSeqGeh], "GEI->GEI_SEQGEH == '" + aCGEH[nGehGe, nGehSeqGeh] + "'",,,,,,.T.)
	nGeiSeqGei := aScan(aHGEI, {| aVet | aVet[2] == "GEI_SEQGEI"})
	nGeiCodPro := aScan(aHGEI, {| aVet | aVet[2] == "GEI_CODPRO"})
	
	/* RELACIONAMENTO CIRURGIA */
	HS_BDados("GEJ", @aHGEJ, @aCGEJ, @nUGEJ, 2, aCGEH[nGehGe, nGehSeqGeh], "GEJ->GEJ_SEQGEH == '" + aCGEH[nGehGe, nGehSeqGeh] + "'",,,,,,.T.)
	nGejSeqGej := aScan(aHGEJ, {| aVet | aVet[2] == "GEJ_SEQGEJ"})
	nGejCodPro := aScan(aHGEJ, {| aVet | aVet[2] == "GEJ_CODPRO"})
	
	/* RELACIONAMENTO MICROBIOLOGIA */
	HS_BDados("GEP", @aHGEP, @aCGEP, @nUGEP, 2, aCGEH[nGehGe, nGehSeqGeh], "GEP->GEP_SEQGEH == '" + aCGEH[nGehGe, nGehSeqGeh] + "'",,,,,,.T.)
	nGepSeqGep := aScan(aHGEP, {| aVet | aVet[2] == "GEP_SEQGEP"})
	nGepCodEsp := aScan(aHGEP, {| aVet | aVet[2] == "GEP_CODESP"})
	
	aAdd(aGehGe, {nGehGe, {}, {}, {}})
	
	aGehGe[Len(aGehGe), 2] := aClone(aCGEI)
	aGehGe[Len(aGehGe), 3] := aClone(aCGEJ)
	aGehGe[Len(aGehGe), 4] := aClone(aCGEP)
	
	For nGepGe := 1 to Len(aCGEP)
		aCGEQ	:= {}; aHGEQ := {}; nUGEQ := 0
		
		/* RELACIONAMENTO FARMACO A MICROBIOLOGIA */
		HS_BDados("GEQ", @aHGEQ, @aCGEQ, @nUGEQ, 2, aCGEP[nGepGe, nGepSeqGep], "GEQ->GEQ_SEQGEP == '" + aCGEP[nGepGe, nGepSeqGep] + "'",,,,,,.T.)
		nGeqSeqGeq  := aScan(aHGEQ, {| aVet | aVet[2] == "GEQ_SEQGEQ"})
		nGeqCodFar  := aScan(aHGEQ, {| aVet | aVet[2] == "GEQ_CODFAR"})
		
		aAdd(aGepGe, {nGehGe, nGepGe, {}})
		aGepGe[Len(aGepGe), 3] := aClone(aCGEQ)
	Next nGepGe
Next nGehGe

nAtGeh := Len(aGehGe)
nAtGep := Len(aGepGe)

DEFINE MSDIALOG oDlg TITLE STR0003 From 000, 000 To 500, 920	PIXEL of oMainWnd //"NOTIFICACAO"
oEncGcy := MsMGet():New("GCY", nRegM31, nOpcM31,,,, aCposGcy, {015, 001, 80, 460}, aCposAlt, 2,,,, oDlg,,,,, .T.)
oEncGcy:oBox:Align := CONTROL_ALIGN_TOP

@ 105,000 FOLDER oFolder1 SIZE 465,450	 OF oDlg PROMPTS STR0004, STR0005 PIXEL              //"Dados da Infeccao"###"Fatores de Risco"
oFolder1:Align := CONTROL_ALIGN_ALLCLIENT

oGEH := MsNewGetDados():New(000, 000, 130, 459, nGDOpc,,,,,,,,,, oFolder1:aDialogs[1], aHGEH, aCGEH)
oGEH:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGEH:bChange := {|| FS_GehCols() }

oGEO := MsNewGetDados():New(000, 000, 130, 459, nGDOpc,,,,,,,,,, oFolder1:aDialogs[2], aHGEO, aCGEO)
oGEO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

@ 130,000 FOLDER oFolder2 SIZE 460,125	 OF oFolder1:aDialogs[1] PROMPTS STR0006, STR0007, STR0008 PIXEL //"Cirurgia"###"Procedimentos de Risco"###"Microbiologia"
oFolder2:Align := CONTROL_ALIGN_BOTTOM

oGEJ := MsNewGetDados():New(000, 000, 65, 459, nGDOpc,,,,,,,,,, oFolder2:aDialogs[1], aHGEJ, aCGEJ)
oGEJ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGEI := MsNewGetDados():New(000, 000, 65, 459, nGDOpc,,,,,,,,,, oFolder2:aDialogs[2], aHGEI, aCGEI)
oGEI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGEP := MsNewGetDados():New(000, 000, 108, 250, nGDOpc,,,,,,,,,, oFolder2:aDialogs[3], aHGEP, aCGEP)
oGEP:oBrowse:Align := CONTROL_ALIGN_LEFT
oGEP:bChange := {|| FS_GepCols() }

oGEQ := MsNewGetDados():New(000, 255, 108, 505, nGDOpc,,,,,,,,,, oFolder2:aDialogs[3], aHGEQ, aCGEQ)
oGEQ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGEH:TudoOk(), oDlg:End(), nOpcA := 0) }, {|| nOpcA := 0, oDlg:End() } )

If nOpcA == 1
	Begin Transaction
	FS_GrvM31()
	End Transaction
	//Mostra as fichas...
	HS_Docs31()
EndIf

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± GRAVA GCY/GEH                    AUTOR: MARCELO JOSE  DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_GrvM31()
Local nForGeh := 0, cAliasOld := Alias(), nPosGD := 0, lFound := .F.
Local nPosGeh := 0, nPosGep := 0

DbSelectArea("GCY")
RecLock("GCY", .F.)
HS_GrvCpo("GCY")
MsUnLock()

/************    GRAVA ARQUIVO DE RELACIONAMENTO DE FATOR */
For nForGeh := 1 To Len(oGEO:aCols)
	DbSelectArea("GEO")
	DbSetOrder(1)
	lFound := IIf(!Empty(oGEO:aCols[nForGeh, nGeoSeqGeo]) .And. !Inclui, DbSeek(xFilial("GEO") + oGEO:aCols[nForGeh, nGeoSeqGeo]), .F.)
	If !oGEO:aCols[nForGeh, nUGEO + 1]
		If !lFound
			M->GEO_SEQGEO := CriaVar("GEO_SEQGEO")
			M->GEO_SEQGEO := HS_VSxeNum("GEO", "M->GEO_SEQGEO", 1)
		Else
			M->GEO_SEQGEO := oGEO:aCols[nForGeh, nGeoSeqGeo]
		EndIf
		RecLock("GEO", !lFound)
		HS_GRVCPO("GEO", oGEO:aCols, oGEO:aHeader, nForGeh)
		GEO->GEO_FILIAL := xFilial("GEO")
		GEO->GEO_SEQGEO := M->GEO_SEQGEO
		GEO->GEO_REGATE := M->GCY_REGATE
		GEO->GEO_LOGARQ := HS_LogArq()
		MsUnlock()
	Else
		If lFound
			RecLock("GEO", .F., .F.)
			DbDelete()
			MsUnLock()
			WriteSx2("GEO")
		EndIf
	Endif
Next

/************   GRAVA ARQUIVO DE RELACIONAMENTO DE DADOS DA INFECCAO */
If (nPosGeh := aScan(aGehGe, {| aVet | aVet[1] == oGEH:nAt})) == 0
	aAdd(aGehGe, { oGEH:nAt, {}, {}, {} } )
	nPosGeh := Len(aGehGe)
EndIf

aGehGe[nPosGeh, 2] := aClone(oGEI:aCols)
aGehGe[nPosGeh, 3] := aClone(oGEJ:aCols)
aGehGe[nPosGeh, 4] := aClone(oGEP:aCols)

If (nPosGep := aScan(aGepGe, {| aVet | aVet[1] == oGEH:nAt .And. aVet[1] == oGEP:nAt})) == 0
	aAdd(aGepGe, {oGEH:nAt, oGEP:nAt, {}})
	nPosGep := Len(aGepGe)
EndIf

aGepGe[nPosGep, 3] := aClone(oGEQ:aCols)

For nForGeh := 1 To Len(oGEH:aCols)
	DbSelectArea("GEH")
	DbSetOrder(1)
	lFound := IIf(!Empty(oGEH:aCols[nForGeh, nGehSeqGeh]) .And. !Inclui, DbSeek(xFilial("GEH") + oGEH:aCols[nForGeh, nGehSeqGeh]), .F.)
	If !oGEH:aCols[nForGeh, nUGeh + 1]
		If !lFound
			M->GEH_SEQGEH := CriaVar("GEH_SEQGEH")
			M->GEH_SEQGEH := HS_VSxeNum("GEH", "M->GEH_SEQGEH", 1)
		Else
			M->GEH_SEQGEH := oGEH:aCols[nForGeh, nGehSeqGeh]
		EndIf
		
		nPosGeh := aScan(aGehGe, {| aVet | aVet[1] == nForGeh})
		
		RecLock("GEH", !lFound)
		HS_GRVCPO("GEH", oGEH:aCols, oGEH:aHeader, nForGeh)
		GEH->GEH_FILIAL := xFilial("GEH")
		GEH->GEH_SEQGEH := M->GEH_SEQGEH
		GEH->GEH_REGATE := M->GCY_REGATE
		GEH->GEH_LOGARQ := HS_LogArq()
		MsUnlock()
		
		FS_GrvGe("GEI", 1, nPosGeh, 2, nUGEI, oGEI:aHeader, "GEI_SEQGEI", nGeiSeqGei, nGeiCodPro)
		FS_GrvGe("GEJ", 1, nPosGeh, 3, nUGEJ, oGEJ:aHeader, "GEJ_SEQGEJ", nGejSeqGej, nGejCodPro)
		FS_GrvGe("GEP", 1, nPosGeh, 4, nUGEP, oGEP:aHeader, "GEP_SEQGEP", nGepSeqGep, nGepCodEsp)
	Else
		If lFound
			FS_DelGe("GEI", 2, GEH->GEH_SEQGEH, "GEI->GEI_SEQGEH == '" + GEH->GEH_SEQGEH + "'")
			FS_DelGe("GEJ", 2, GEH->GEH_SEQGEH, "GEJ->GEJ_SEQGEH == '" + GEH->GEH_SEQGEH + "'")
			FS_DelGe("GEP", 2, GEH->GEH_SEQGEH, "GEP->GEP_SEQGEH == '" + GEH->GEH_SEQGEH + "'")
			
			RecLock("GEH", .F., .F.)
			DbDelete()
			MsUnLock()
			WriteSx2("GEH")
		Endif
	Endif
Next

DbSelectArea(cAliasOld)
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± GRAVA GEI/GEJ/GEP                AUTOR:  JOSE ORFEU   DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_GrvGe(cAlias, nOrdem, nPosGe, nDesp, nUGe, aHGe, cCpoCh, nGeCodSeq, nGeCodVld)
Local nForGe := 0, lFound := .F., aCGe := {}
Local cPArq   := cAlias + "->" + PrefixoCpo(cAlias)
Local cArqCpo := cAlias + "->" + cCpoCh
Local cMemCpo :=         "M->" + cCpoCh

aCGe := aClone(aGehGe[nPosGe, nDesp])

For nForGe := 1 To Len(aCGe)
	If !Empty(aCGe[nForGe, nGeCodVld])
		DbSelectArea(cAlias)
		DbSetOrder(nOrdem)
		lFound := IIf( !Empty(aCGe[nForGe, nGeCodVld]) .And. !Inclui , DbSeek(xFilial(cAlias) + aCGe[nForGe, nGeCodSeq] ), .F.)
		
		If !aCGe[nForGe, nUGe + 1]
			If !lFound
				&(cMemCpo) := CriaVar(StrTran(cMemCpo, "M->", ""))
				&(cMemCpo) := HS_VSxeNum(cAlias, cMemCpo, nOrdem)
			Else
				&(cMemCpo) := aCGe[nForGe, nGeCodSeq]
			EndIf
			
			RecLock(cAlias, !lFound)
			HS_GRVCPO(cAlias, aCGe, aHGe, nForGe)
			&(cPArq + "_FILIAL") := xFilial(cAlias)
			&(cArqCpo)           := &(cMemCpo)
			&(cPArq + "_SEQGEH") := GEH->GEH_SEQGEH
			&(cPArq + "_REGATE") := GCY->GCY_REGATE
			&(cPArq + "_LOGARQ") := HS_LogArq()
			MsUnlock()
			
			FS_GrvGeq(nPosGE, nForGe)
		Else
			If lFound
				RecLock(cAlias, .F., .F.)
				DbDelete()
				MsUnLock()
				WriteSx2(cAlias)
				
				FS_DelGeq(nPosGE, nForGE)
			EndIf
		EndIf
	Endif
Next

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± GRAVA GEQ                        AUTOR: JOSE ORFEU    DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_GrvGeq(nPosGeh, nPosGep)
Local nForGeq := 0, lFound := .F., aColsGeq := {}
Local nPosGeq := 0

nPosGeq  := aScan(aGepGe, {| aVet | aVet[1] == nPosGeh .And. aVet[2] == nPosGep})

If nPosGeq <= 0
	Return(Nil)
EndIf

aColsGeq := aClone(aGepGe[nPosGeq, 3])

For nForGeq := 1 To Len(aColsGeq)
	If !Empty(aColsGeq[nForGeq, nGeqCodFar])
		DbSelectArea("GEQ")
		DbSetOrder(1)
		lFound := IIf( !Empty(aColsGeq[nForGeq, nGeqCodFar]) .And. !Inclui , DbSeek(xFilial("GEQ") + aColsGeq[nForGeq, nGeqSeqGeq] ), .F.)
		
		If !aColsGeq[nForGeq, nUGeq + 1]
			If !lFound
				M->GEQ_SEQGEQ := CriaVar("GEQ_SEQGEQ")
				M->GEQ_SEQGEQ := HS_VSxeNum("GEQ", "M->GEQ_SEQGEQ", 1)
			Else
				M->GEQ_SEQGEQ := aColsGeq[nForGeq, nGeqSeqGeq]
			EndIf
			
			RecLock("GEQ", !lFound)
			HS_GRVCPO("GEQ", aColsGeq, aHGeq, nForGeq)
			GEQ->GEQ_FILIAL := xFilial("GEQ")
			GEQ->GEQ_SEQGEQ := M->GEQ_SEQGEQ
			GEQ->GEQ_SEQGEP := GEP->GEP_SEQGEP
			GEQ->GEQ_SEQGEH := GEH->GEH_SEQGEH
			GEQ->GEQ_REGATE := GCY->GCY_REGATE
			GEQ->GEQ_LOGARQ := HS_LogArq()
			MsUnlock()
		Else
			If lFound
				RecLock("GEQ", .F., .F.)
				DbDelete()
				MsUnLock()
				WriteSx2("GEQ")
			EndIf
		EndIf
	Endif
Next

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  APAGA REGISTROS                 AUTOR:  JOSE ORFEU   DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                         
Static Function FS_DelGe(cAlias, nOrdem, cChave, cCond)

cCond := StrTran(cCond, cAlias + "->", "")
cCond := StrTran(cCond, "==", "=")
cCond := StrTran(cCond, ".", "")
TCSQLExec("UPDATE " + RetSqlName(cAlias) + " SET D_E_L_E_T_ = '*' WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cCond)

Return(Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± REFAZ GETDADOS ANEXAS            AUTOR: JOSE ORFEU    DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION FS_GehCols()
Local nPosACols := 0, nForGD := 0
cGehSitPri:= oGEH:aCols[oGEH:nAt, nGehSitPri]

If nAtGeh <> oGEH:nAt
	If (nPosACols := aScan(aGehGe, {| aVet | aVet[1] == nAtGeh})) == 0
		aAdd(aGehGe, { nAtGeh, {}, {}, {} } )
		nPosACols := Len(aGehGe)
	EndIf
	aGehGe[nPosACols, 2] := aClone(oGEI:aCols)
	aGehGe[nPosACols, 3] := aClone(oGEJ:aCols)
	aGehGe[nPosACols, 4] := aClone(oGEP:aCols)
	
	If (nPosACols := aScan(aGehGe, {| aVet | aVet[1] == oGEH:nAt})) > 0
		oGEI:SetArray(aGehGe[nPosACols, 2])
		oGEJ:SetArray(aGehGe[nPosACols, 3])
		oGEP:SetArray(aGehGe[nPosACols, 4])
	Else
		oGEI:aCols := {}
		oGEI:AddLine(.T., .F.)
		
		oGEJ:aCols := {}
		oGEJ:AddLine(.T., .F.)
		
		oGEP:aCols := {}
		oGEP:AddLine(.T., .F.)
	EndIf
	
	FS_GepCols()
	
	oGEI:oBrowse:Refresh()
	oGEJ:oBrowse:Refresh()
	oGEP:oBrowse:Refresh()
	
	nAtGeh := oGEH:nAt
EndIf
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± REFAZ GETDADOS GEP               AUTOR: JOSE ORFEU    DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION FS_GepCols()
Local nPosACols := 0, nForGD := 0

If nAtGeh <> oGeh:nAt .Or. nAtGep <> oGEP:nAt
	If (nPosACols := aScan(aGepGe, {| aVet | aVet[1] == nAtGeh .And. aVet[2] == nAtGep})) == 0
		aAdd(aGepGe, {nAtGeh, nAtGep, {}})
		nPosACols := Len(aGepGe)
	EndIf
	
	aGepGe[nPosACols, 3] := aClone(oGEQ:aCols)
	
	If (nPosACols := aScan(aGepGe, {| aVet | aVet[1] == oGEH:nAt .And. aVet[2] == oGEP:nAt})) > 0
		oGEQ:SetArray(aGepGe[nPosACols, 3])
	Else
		oGEQ:aCols := {}
		oGEQ:AddLine(.T., .F.)
	EndIf
	
	oGEQ:oBrowse:Refresh()
	
	nAtGep := oGEP:nAt
EndIf
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± VALIDA INCLUSOES DA NOTIFICACAO  AUTOR: MARCELO JOSE  DATA:26/04/2005   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION HS_VLNOT(nVemValid)
Local lRet := .F. , cPar

If nVemValid == 1  /* VALIDA PROCEDIMENTO */
	IF HS_SeekRet("SX5","'PR'+M->GEI_CODPRO",1,.f.,"GEI_DESPRO","X5_DESCRI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)   //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 2  /* VALIDA CLINICA */
	If HS_SeekRet("GCW","M->GEH_CODCLI",1,.f.,"GEH_DESCLI","GCW_DESCLI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 3  /* VALIDA PROCEDIMENTO */
	If HS_SeekRet("GA7","M->GEJ_CODPRO",1,.f.,"GEJ_DESPRO","GA7_DESC")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 4  /* VALIDA TOPOGRAFIA (LOCAL DE INFECCAO) */
	If HS_SeekRet("SX5","'LI'+M->GEJ_CODTOP",1,.f.,"GEJ_DESTOP","X5_DESCRI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 5  /* VALIDA PORTE CIRURGICO */
	If HS_SeekRet("SX5","'PC'+M->GEJ_CODPOR",1,.f.,"GEJ_DESPOR","X5_DESCRI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)   //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 6  /* VALIDA TIPO DE ANESTESIA */
	If HS_SeekRet("SX5","'CA'+M->GEJ_TPANES",1,.f.,"GEJ_DESANE","X5_DESCRI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 7  /* VALIDA CLASSIFICACAO CIRURGICA */
	If HS_SeekRet("SX5","'CQ'+M->GEJ_CLACIR",1,.f.,"GEJ_DESCLA","X5_DESCRI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 8
	IF !EMPTY(M->GCY_TPALTA)
		cPar := AllTrim(GetMv("MV_TPALTA"))
		If  M->GCY_OBTINF == "1"
			If M->GCY_TPALTA $ cPar
				lRet := .T.
			Else
				HS_MsgInf(STR0011,STR0010,STR0021)  //"Este Campo so pode ser SIM se o tipo de ALTA for por OBITO."###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
				M->GCY_OBTINF := " "
			EndIf
		Else
			lRet := .T.
		EndIf
	Else
		HS_MsgInf(STR0012,STR0010,STR0021)  //"Tipo da Alta esta vazio...operacao invalida."###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
		M->GCY_OBTINF := " "
		lRet := .T.
	EndIf
ElseIf nVemValid == 9  /* VALIDA MICROORGANISMO */
	If HS_SeekRet("GDH","M->GEP_CODMIC",1,.f.,"GEP_DESMIC","GDH_NOMVIR")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 10  /* VALIDA ESPECIME */
	If HS_SeekRet("GEM","M->GEP_CODESP",1,.f.,"GEP_DESESP","GEM_DESCRI")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 11  /* VALIDA SITIO PRINCIPAL */
	If HS_SeekRet("GEK","M->GEH_SITPRI",1,.f.,"GEH_DESPRI","GEK_DESCRI") .OR. VAZIO()
		lRet := .T.
		cGehSitPri := M->GEH_SITPRI
		oGEH:aCols[oGEH:nAt, nGehSitEsp]:= space(len(oGEH:aCols[oGEH:nAt, nGehSitEsp]))
		oGEH:aCols[oGEH:nAt, nGehNomEsp]:= space(len(oGEH:aCols[oGEH:nAt, nGehNomEsp]))
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 12  /* VALIDA SITIO ESPECIFICO */
	If Empty(oGEH:aCols[oGEH:nAt, nGehSitPri])
		HS_MsgInf(STR0013,STR0010,STR0021) //"E necessario informar o sitio principal para efetuar a escolha do sitio especifico" //"VALIDA INCLUSOES DA NOTIFICACAO"
	Else
		If HS_SeekRet("GEW","M->GEH_SITESP",1,.f.,"GEH_DESESP","GEW_DESCRI") .OR. VAZIO()
			lRet := .T.
		Else
			HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
		EndIf
	Endif
ElseIf nVemValid == 13  /* VALIDA SITIO ESPECIFICO */
	If HS_SeekRet("GA0","M->GEQ_CODFAR",1,.f.,"GEQ_DESC","GA0_DESC")
		lRet := .T.
	Else
		HS_MsgInf(STR0009,STR0010,STR0021)    //"Registro NAO Encontrado"###"Atencao" //"VALIDA INCLUSOES DA NOTIFICACAO"
	EndIf
ElseIf nVemValid == 14  /* DATA DA INFECCAO DA ABA DADOS DA INFECCAO */
	
	IF M->GEH_DATINF < GCY->GCY_DATATE
		HS_MsgInf(STR0014,STR0010,STR0021) //"Data da Infeccao MENOR que a data de Atendimento...Operacao invalida." //"VALIDA INCLUSOES DA NOTIFICACAO"
		lRet := .F.
	Else
		IF !Empty(GCY->GCY_DATALT)
			IF M->GEH_DATINF > DdataBase
				HS_MsgInf(STR0022,STR0010,STR0021) //"Data da Infeccao MAIOR que a data base...Operacao invalida." //"VALIDA INCLUSOES DA NOTIFICACAO"
				lRet := .F.
			Else
				lRet := .T. 
			ENDIF
		ELSE
			lRet := .T.  
		ENDIF
	ENDIF
	
ElseIf nVemValid == 15  /* DATA DA ENTRADA DA ABA DADOS DA INFECCAO */
	
	IF M->GEH_DATCLI < GCY->GCY_DATATE
		HS_MsgInf(STR0016,STR0010,STR0021) //"Data da Entrada MENOR que a data de Atendimento...Operacao invalida." //"VALIDA INCLUSOES DA NOTIFICACAO"
		lRet := .F.
	Else
		IF !Empty(GCY->GCY_DATALT)
			IF M->GEH_DATCLI > GCY->GCY_DATALT
				HS_MsgInf(STR0017,STR0010,STR0021) //"Data da Entrada MAIOR que a data da Alta...Operacao invalida." //"VALIDA INCLUSOES DA NOTIFICACAO"
				lRet := .F.
			Else
				lRet := .T.
			ENDIF
		ELSE
			lRet := .T.
		ENDIF
	ENDIF
ElseIf nVemValid == 16  /* DATA DA CIRURGIA */
	
	IF M->GEJ_DATCIR < GCY->GCY_DATATE
		HS_MsgInf(STR0018,STR0010,STR0021) //"Data da Cirurgia MENOR que a data de Atendimento...Operacao invalida." //"VALIDA INCLUSOES DA NOTIFICACAO"
		lRet := .F.
	Else
		IF !Empty(GCY->GCY_DATALT)
			IF M->GEJ_DATCIR > GCY->GCY_DATALT
				HS_MsgInf(STR0019,STR0010,STR0021) //"Data da Cirurgia MAIOR que a data da Alta...Operacao invalida." //"VALIDA INCLUSOES DA NOTIFICACAO"
				lRet := .F.
			Else
				lRet := .T.
			ENDIF
		ELSE
			lRet := .T.
		ENDIF
	ENDIF
	
EndIf

RETURN(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      ATIVA FILTRO DO BROWSE                                             ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_FilM31(lSetFilter)
Local oObjMBrw := IIf(lSetFilter, GetObjBrow(), Nil)
Local cPar05 := "", lRet := .F.

If (lRet := Pergunte("HSPM31"))
	If MV_PAR05 == 1	 /* Ambulatorio */
		cPar05 := "1"
	ElseIf MV_PAR05 == 2	 /* PA */
		cPar05 := "2"
	ElseIf MV_PAR05 == 3	 /* Internacao */
		cPar05 := "0"
	EndIf
	
	cFilM31 := "GCY_FILIAL = '" + xFilial("GCY") + "'"
	
	If !EMPTY(MV_PAR01)
		cFilM31 += " AND GCY_DATATE >= '" + DToS(MV_PAR01) + "'"
	EndIf
	
	If !EMPTY(MV_PAR02)
		cFilM31 += " AND GCY_DATATE <= '" + DToS(MV_PAR02) + "'"
	EndIf
	
	If !EMPTY(MV_PAR03)
		cFilM31 += " AND GCY_DATALT >= '" + DToS(MV_PAR03) + "'"
	EndIf
	
	If !EMPTY(MV_PAR04)
		cFilM31 += " AND GCY_DATALT <= '" + DToS(MV_PAR04) + "'"
	EndIf
	
	If MV_PAR05 < 4
		cFilM31 += " AND GCY_ATENDI = '" + cPar05 + "'"
	EndIf
	
	If lSetFilter
		SetMBTopFilter("GCY", cFilM31)
		oObjMBrw:GoTop()
		oObjMBrw:Refresh()
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DOCS   ºAutor  ³Luiz Pereira S. Jr. º Data ³  11/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a chamada da funcao para exibir as fichas               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HSP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_Docs31()

GDN->(dbSetOrder(1))
If GDN->(DbSeek(xFilial("GDN") + GCY->GCY_LOCATE))
	HSPAHP44(.F., GCY->GCY_LOCATE)
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},; //"Pesquisar"
             		 {OemToAnsi(STR0003), "HS_Notifi", 0, 4, 0, nil},; //"Notificacao"
             		 {OemToAnsi(STR0020), "HS_Docs31", 0, 2, 0, nil}}  //Doctos
Return(aRotina)
