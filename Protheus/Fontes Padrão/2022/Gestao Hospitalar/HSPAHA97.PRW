#INCLUDE "HSPAHA97.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA97  บ Autor ณ Paulo Jose         บ Data ณ  16/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE DISPONIBILIDADE MEDICA                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA97()
Private aRotina := MenuDef()

If !HS_ExisDic({{"T", "GO3","FNC 148152"}})
	Return(nil)
EndIf

mBrowse(06, 01, 22, 75, "GM6")

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | HS_A97   บ Autor ณ PAULO JOSE         บ Data ณ 16/11/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Manutecao de Disponibilide Medica                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A97(cAlias, nReg, nOpc)

Local nCntFor := 0
Local nOpcA := 0, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local bFS_Facili	:= {||FS_FACILI()} // Facilitador para inclusao dos relacionamentos
Local aButtons := {}, bKeyF12, aJoin := {}

Private nGM5_DIASEM := 0, nGM5_IDEATI := 0, nLINGM5 := 0
Private nGMK_ITEDIA := 0, nGMK_DIASEM := 0, nGMK_HORINI := 0, nGMK_HORFIN := 0, nGMK_CODREC := 0, nLINGMK := 0
Private nGM4_CODLOC := 0, nGM4_CODPLA := 0, nGM4_DESPLA := 0, nGM4_IDEATI := 0, nLINGM4 := 0
Private nGM3_CODLOC := 0, nGM3_CODPRO := 0, nGM3_DESPRO := 0, nGM3_IDEATI := 0, nLINGM3 := 0
Private oGM5, aHGM5 := {}, aCGM5 := {}, nUGM5 := 0
Private oGM4, aHGM4 := {}, aCGM4 := {}, nUGM4 := 0
Private oGMK, aHGMK := {}, aCGMK := {}, nUGMK := 0
Private oGM3, aHGM3 := {}, aCGM3 := {}, nUGM3 := 0, aCGM3W  := {}, nUGM3W := 0

Private nGO3_CODREC := 0, nGO3_DESREC := 0,nGO3_STATUS := 0, nLINGO3 := 0
Private oGO3, aHGO3 := {}, aCGO3 := {}, nUGO3 := 0

Private oFolder, pForACols := 0
Private aTela := {}, aGets := {}
Private cGcsTipLoc := "1"  //Tipo de Local utilizado no filtro da consulta padrao GCS. Tem que ser com este nome de variavel.
Private cGcsCodLoc := ""   //Codigo do setor a ser selecionado no filtro dos procedimentos por setor (GM2) - HS_FilGm2()
Private __cCodSal  := ""   //Codigo da sala a ser selecionado no filtro dos recursos por sala (GO2) - HS_FilGO2()
Private lDicStatu := HS_EXISDIC({{"C", "GO3_STATUS"}},.F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inclusao dos botoes dos facilitadores ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aButtons, {'PARAMETROS', {||Eval(bFS_Facili)}, STR0028, STR0052}) //"Facilitador p/ inclusใo de itens no relacionamento"###"Itens"
bKeyF4 := SetKey(VK_F4, { || Eval(bFS_Facili)})

// Cria as Variaveis de Memoria do GM6
RegToMemory(cAlias, nOpc == 3)

// Inicializa os vetores do MsNewGetDados GM5
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GM5->GM5_CODDIS", Nil)
nLINGM5 := HS_BDados("GM5", @aHGM5, @aCGM5, @nUGM5, 1,, cCond )
nGM5_DIASEM := aScan(aHGM5, {| aVet | aVet[2] == "GM5_DIASEM"})
nLINGM5 := (IIf(Len(aCGM5) == 1 .And. Empty(aCGM5[1, nGM5_DIASEM]), 0, Len(aCGM5) ))

// Inicializa os vetores do MsNewGetDados GM4 - Disponibilidade / Planos Nao Atendidos
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GM4->GM4_CODDIS", Nil)
aJoin := {{" LEFT JOIN " + RetSqlName("GCM") + " GCM ", "GCM.GCM_DESPLA" , "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GM4.GM4_CODPLA ", "GM4_DESPLA"}}

nLINGM4 := HS_BDados("GM4", @aHGM4, @aCGM4, @nUGM4, 1,, cCond,,,,,,,,,,,, .T.,,,, aJoin)
nGM4_CODPLA := aScan(aHGM4, {| aVet | aVet[2] == "GM4_CODPLA"})
nGM4_DESPLA := aScan(aHGM4, {| aVet | aVet[2] == "GM4_DESPLA"})
nGM4_CODLOC := aScan(aHGM4, {| aVet | aVet[2] == "GM4_CODLOC"})
nLINGM4 := (IIf(Len(aCGM4) == 1 .And. Empty(aCGM4[1, nGM4_CODPLA]), 0, Len(aCGM4) ))

cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GM3->GM3_CODDIS", Nil)
aJoin := {{" LEFT JOIN " + RetSqlName("GA7") + " GA7 ", "GA7.GA7_DESC", "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GM3.GM3_CODPRO ", "GM3_DESPRO"}}

nLINGM3 := HS_BDados("GM3", @aHGM3, @aCGM3, @nUGM3, 1,, cCond,,,,,,,,,,,, .T.,,,, aJoin)
nGM3_CODLOC := aScan(aHGM3, {| aVet | aVet[2] == "GM3_CODLOC"})
nGM3_CODPRO := aScan(aHGM3, {| aVet | aVet[2] == "GM3_CODPRO"})
nGM3_DESPRO := aScan(aHGM3, {| aVet | aVet[2] == "GM3_DESPRO"})
nLINGM3 := (IIf(Len(aCGM3) == 1 .And. Empty(aCGM3[1, nGM3_CODPRO]), 0, Len(aCGM3)))

// Inicializa os vetores do MsNewGetDados GMK
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GMK->GMK_CODDIS", Nil)
nLINGMK := HS_BDados("GMK", @aHGMK, @aCGMK, @nUGMK, 1, M->GM6_CODDIS, cCond )
nGMK_ITEDIA := aScan(aHGMK, {| aVet | aVet[2] == "GMK_ITEDIA"})
nGMK_DIASEM := aScan(aHGMK, {| aVet | aVet[2] == "GMK_DIASEM"})
nGMK_HORINI := aScan(aHGMK, {| aVet | aVet[2] == "GMK_HORINI"})
nGMK_HORFIN := aScan(aHGMK, {| aVet | aVet[2] == "GMK_HORFIN"})
nGMK_CODREC := aScan(aHGMK, {| aVet | aVet[2] == "GMK_CODREC"})
If Empty(aCGMK[1, nGMK_ITEDIA])
	aCGMK[1, nGMK_ITEDIA]	:= StrZero(1, Len(aCGMK[1, nGMK_ITEDIA]))
Endif
nLINGMK := (IIf(Len(aCGMK) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(aCGMK)))

If Inclui
	aHGM3W := aClone(aHGM3)
	aCGM3W := aClone(aCGM3)
ElseIf Altera
	cGcsCodLoc := GM6->GM6_CODLOC
EndIf

__cCodSal := GM6->GM6_CODSAL
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GO3->GO3_CODDIS", Nil)
nLINGO3 := HS_BDados("GO3", @aHGO3, @aCGO3, @nUGO3, 1,, cCond,,,,,,,,,,,, .T.)
nGO3_CODREC := aScan(aHGO3, {| aVet | aVet[2] == "GO3_CODREC"})
nGO3_DESREC := aScan(aHGO3, {| aVet | aVet[2] == "GO3_DESREC"})
If  lDicStatu
	nGO3_STATUS := aScan(aHGO3, {| aVet | aVet[2] == "GO3_STATUS"})
Endif

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd(aObjects, {100, 050, .T., .T.})
AAdd(aObjects, {100, 050, .T., .T.})

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize( aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd //"Disponibilidade M้dica"

oEnchoi:= MsMGet():New(cAlias, nReg, nOpc,,,,,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oEnchoi:oBox:Align := CONTROL_ALIGN_TOP

@ 120, 000 FOLDER oFolder SIZE 317, 217 OF oDlg PROMPTS STR0007, STR0008, STR0009, STR0059, "Recurso" PIXEL //"Dia da Semana"###"Planos nใo Atendidos"###"Procedimentos"###"Perํodos Indisponํveis"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

oGM5 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , , , , , 99999, , , , oFolder:aDialogs[1], aHGM5, aCGM5)
oGM5:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGM4 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , , , , , 99999, , , , oFolder:aDialogs[2], aHGM4, aCGM4)
oGM4:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGM3 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , , , , , 99999, , , , oFolder:aDialogs[3], aHGM3, aCGM3)
oGM3:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGMK := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_DuplAC(oGMK:oBrowse:nAt, oGMK:aCols, {nGMK_DIASEM,nGMK_HORINI,nGMK_HORFIN,nGMK_CODREC})",,"+GMK_ITEDIA", , , 99999, , , , oFolder:aDialogs[4], aHGMK, aCGMK)
oGMK:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGMK:bLinhaOK	:= { || FS_VLDGMK(oGMK,nGMK_DIASEM,nGMK_HORINI,nGMK_HORFIM, nGMK_CODREC)}
//FS_DUPLGMK

oGO3 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_DuplAC(oGO3:oBrowse:nAt, oGO3:aCols, {nGO3_CODREC},, .T.)", , , , , 99999, , , , oFolder:aDialogs[5], aHGO3, aCGO3)
oGO3:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

nOpcA := 0
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And. HS_TUDOOK("GM5",	 oGM5, nGM5_DIASEM) ;
										.And. HS_TUDOOK("GM4", oGM4, nGM4_CODPLA) 	.And. HS_TUDOOK("GM3", oGM3, nGM3_CODPRO) .And. ;
										FS_VLDGMK(oGMK,nGMK_DIASEM,nGMK_HORINI,nGMK_HORFIM, nGMK_CODREC) .And. HS_TUDOOK("GMK", oGMK, nGMK_DIASEM) .And. HS_TUDOOK("GO3", oGO3, nGO3_CODREC) .And. ;
										FS_VLCols(aCGM5, aCGM3, aCGO3, nOpc) .And. FS_VldDisp(), ;
										oDlg:End(), 	nOpcA := 0)},  ;
										{|| nOpcA := 0, oDlg:End()},, aButtons)

SetKey(VK_F4, bKeyF4)

If nOpca == 1
	FS_GrvA97(nOpc)
Else
	While __lSx8
		RollBackSx8()
	End
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA97 บ Autor ณ Paulo Jose         บ Data ณ  18/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ  Valida os campos                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar (Agenda Ambulatorial)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldA97()

Local lRet     := .T., nPos := 0, nForACols := 0, cAliasOld := Alias()
Local nLinTGM4 := 0
Local nLinTGM3 := 0
Local nLinTGMK := 0
Local nHoraFim := 0
Local nMinFim  := 0
Local nMinInt  := 0
Local cUltHor  := ""

//Valida dia da Semana
If ReadVar() == "M->GM5_DIASEM"
	
	If M->GM5_DIASEM $ "12345678"
		
		nPos := aScan(oGM5:aCols, {| aVet | aVet[nGm5_DIASEM] == M->GM5_DIASEM})
		If nPos > 0 .And. nPos # oGM5:oBrowse:nAt
			HS_MsgInf(STR0010, STR0011, STR0053) //"Dia da Semana jแ cadastrado"###"Aten็ใo"###"Valida็ใo dos Campos"
			lRet := .F.
		EndIf
		
	Else
		
		HS_MsgInf(STR0012, STR0011, STR0053) //"Dia da Semana Invแlido"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
		
	EndIf
	
ElseIf ReadVar() == "M->GMK_DIASEM"
	
	If !M->GMK_DIASEM $ "12345678"
		HS_MsgInf(STR0012, STR0011, STR0053) //"Dia da Semana Invแlido"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	ElseIf 	(nPos := aScan(oGM5:aCols, {| aVet | aVet[nGM5_DIASEM] == M->GMK_DIASEM})) == 0
		HS_MsgInf(STR0060, STR0011, STR0053) //"Dia da Semana nใo cadastrado na aba Dia da Semana"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
	
ElseIf ReadVar() == "M->GMK_HORINI"
	
	If M->GMK_HORINI < M->GM6_HORINI
		HS_MsgInf(STR0061, STR0011, STR0053) //"Horแrio nใo pode ser menor que o horแrio inicial da disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	ElseIf M->GMK_HORINI == M->GM6_HORINI .And. oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorFin] == M->GM6_HORFIM
		HS_MsgInf(STR0062, STR0011, STR0053) //"Horแrios inicial/final iguais aos horแrios da disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	ElseIf M->GMK_HORINI > M->GM6_HORFIM
		HS_MsgInf(STR0063, STR0011, STR0053) //"Horแrios inicial nใo pode ser maior que o horแrio final da disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
	
	/*If lRet
		nLinTGMK := IIf ( Len(aCGMK) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(aCGMK) )
		For nForACols := 1 To nLinTGMK
			If nForACols # oGMK:oBrowse:nAt .And. oGMK:aCols[nForACols, nGMK_DiaSem] == oGMK:aCols[oGMK:oBrowse:nAt, nGMK_DiaSem] .And. !oGMK:aCols[nForACols, nUGMK + 1] .And. ;
				(M->GMK_HORINI >= oGMK:aCols[nForACols, nGMK_HorIni] .And. M->GMK_HORINI <= oGMK:aCols[nForACols, nGMK_HorFin] .Or. ;
				(M->GMK_HORINI < oGMK:aCols[nForACols, nGMK_HorIni] .And. oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorFin] >= oGMK:aCols[nForACols, nGMK_HorIni]))
				HS_MsgInf(STR0064, STR0011, STR0053) //"Perํodo coincidente com os perํodos jแ cadastrados para esse dia"###"Aten็ใo"###"Valida็ใo dos Campos"
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf*/
	
ElseIf ReadVar() == "M->GMK_HORFIN"   
//permite informar o horario final de atendimento + o valor de um intervalo medico, para que seja possivel bloquear o ultimo horario.
nHoraFim := VAL(SUBSTR(M->GM6_HORFIM,1,2))
nMinFim  := VAL(SUBSTR(M->GM6_HORFIM,4,2))
nMinInt  := VAL(SUBSTR(M->GM6_INTMAR,4,2)) 
nMinFim := nMinFim + nMinInt

If nMinFim > 60
	nHoraFim += 1
	nMinFim	:= nMinFim - 60
EndIf

If nMinFim == 60
	nHoraFim += 1
	nMinFim	:= 0
EndIf 

cUltHor := cValTochar(nHoraFim) + ":" + cValTochar(nMinFim)
	
	If M->GMK_HORFIN > cUltHor
		HS_MsgInf(STR0065, STR0011, STR0053) //"Horแrio nใo pode ser maior que o horแrio final da disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	ElseIf oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorIni] == M->GM6_HORINI .And.  M->GMK_HORFIN == M->GM6_HORFIM
		HS_MsgInf(STR0062, STR0011, STR0053) //"Horแrios inicial/final iguais aos horแrios da disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	ElseIf M->GMK_HORFIN < M->GM6_HORINI
		HS_MsgInf(STR0066, STR0011, STR0053) //"Horแrios final nใo pode ser menor que o horแrio inicial da disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
	
/*	If lRet
		nLinTGMK := IIf(Len(aCGMK) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(aCGMK))
		For nForACols := 1 To nLinTGMK
			If nForACols # oGMK:oBrowse:nAt .And. oGMK:aCols[nForACols, nGMK_DiaSem] == oGMK:aCols[oGMK:oBrowse:nAt, nGMK_DiaSem] .And. !oGMK:aCols[nForACols, nUGMK + 1] .And. ;
				(M->GMK_HORFIN <= oGMK:aCols[nForACols, nGMK_HorFin] .And. M->GMK_HORFIN >= oGMK:aCols[nForACols, nGMK_HorIni] .Or. ;
				(M->GMK_HORFIN > oGMK:aCols[nForACols, nGMK_HorFin] .And. oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorIni] <= oGMK:aCols[nForACols, nGMK_HorFin]))
				HS_MsgInf(STR0064, STR0011, STR0053) //"Perํodo coincidente com os perํodos jแ cadastrados para esse dia"###"Aten็ใo"###"Valida็ใo dos Campos"
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf   */
	
ElseIf ReadVar() == "M->GM6_IDEATI"
	If M->GM6_IDEATI == "1" .And. !Inclui
		DbSelectArea("GM2")
		DBSetOrder(1) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
		nLinTGM3 := IIf(Len(aCGM3) == 1 .And. Empty(aCGM3[1, nGM3_CODPRO]), 0, Len(aCGM3))
		For nForACols := 1 To nLinTGM3
			
			If !DbSeek(xFilial("GM2") + M->GM6_CODLOC + oGM3:aCols[nForACols, nGM3_CODPRO])
				HS_MsgInf(STR0013 + oGM3:aCols[nForACols, nGM3_CODPRO] + "/" + oGM3:aCols[nForACols, nGM3_DESPRO] + STR0014, STR0011, STR0009)  //"O Procedimento ("###") nใo estแ cadastrado em Setor x Procedimento"###"Aten็ใo"###"Procedimentos"
				lRet := .F.
			EndIf
		Next
		
		DbSelectArea("GCM")
		DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
		nLinTGM4 := IIf(Len(aCGM4) == 1 .And. Empty(aCGM4[1, nGM4_CODPLA]), 0, Len(aCGM4) )
		For nForACols := 1 To nLinTGM4
			
			If !DbSeek(xFilial("GCM") + oGM4:aCols[nForACols, nGM4_CODPLA])
				HS_MsgInf(STR0015 + Trim(oGM4:aCols[nForACols, nGM4_CODPLA] + "/" + oGM4:aCols[nForACols, nGM4_DESPLA]) + STR0016, STR0011, STR0053) //"O plano ("###") nใo estแ cadastrado em Plano"###"Aten็ใo"###"Valida็ใo dos Campos"
				lRet := .F.
			EndIf
			
		Next
	EndIf
	
	//Valida Disponibilidade Medica
ElseIf ReadVar() == "M->GM6_CODLOC"
	If !HS_SeekRet("GCS", "M->GM6_CODLOC", 1, .F., "GM6_NOMLOC", "GCS_NOMLOC",,, .T.)
		HS_MsgInf(STR0017, STR0011, STR0053) //"Setor invแlido"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	Else
		If GCS->GCS_TIPLOC <> "1"
			HS_MsgInf(STR0034, STR0011, STR0053)//"Setor invแlido. Utilize um setor do tipo Ambulatorial"###"Aten็ใo"###"Valida็ใo dos Campos"
			lRet := .F.
		Else
			cGcsCodLoc := GCS->GCS_CODLOC
			If Inclui
				aHGM3 := aClone(aHGM3W)
				aCGM3 := aClone(aCGM3W)
				oGM3:aCols := aClone(aCGM3)
				oGM3:Refresh()
			EndIf
		EndIf
	EndIf
	
	//VALIDA LIBERAวรO DE DISPONIBILIDADE
ElseIf ReadVar() == "M->GM6_CODCRM"
	If !HS_SeekRet("SRA", "M->GM6_CODCRM", 11, .F., "GM6_NOMCRM", "RA_NOME",,, .T.)
		HS_MsgInf(STR0018, STR0011, STR0053) //"CRM do M้dico invแlido"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	Else
		If !(HS_IniPadr("GBJ", 1, M->GM6_CODCRM, "GBJ_IDAGEN",, .F.) $ "0/2" )
			HS_MsgInf(STR0038, STR0011, STR0053)  //"CRM do M้dico Invแlido! M้dico Nใo Habilitado para Incluir uma Disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
			lRet := .F.
		EndIf
	EndIf
ElseIf ReadVar() == "M->GM6_HORINI"
	If !FS_VldHA97(M->GM6_HORINI)
		HS_MsgInf(STR0019, STR0011, STR0053)  //"Hora inicial invแlida"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
ElseIf ReadVar() == "M->GM6_HORFIM"
	If !FS_VldHA97(M->GM6_HORFIM)
		HS_MsgInf(STR0020, STR0011, STR0053)  //"Hora final invแlida"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	ElseIf (M->GM6_HORFIM < M->GM6_HORINI)
		HS_MsgInf(STR0021, STR0011, STR0053)  //"Hora final menor que hora inicial."###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
ElseIf ReadVar() == "M->GM6_HORENC"
	If M->GM6_HORENC <> "  :  " .And. (Empty(M->GM6_HORFIM) .Or. Empty(M->GM6_HORINI))
		HS_MsgInf(STR0067, STR0011, STR0053)  //"Digite as horas inicial e final"###"Atencao"###"valida็ใo dos Campos"
		lRet := .F.
	ElseIf M->GM6_HORENC <> "  :  " .And. !FS_VldHA97(M->GM6_HORENC)
		HS_MsgInf(STR0068, STR0011, STR0053)  //"Hora limite para encaixe invแlida"###"Atencao"###"valida็ใo dos Campos"
		lRet := .F.
	ElseIf M->GM6_HORENC <> "  :  " .And. (M->GM6_HORENC < M->GM6_HORINI .Or. M->GM6_HORENC > M->GM6_HORFIM)
		HS_MsgInf(STR0069, STR0011, STR0053)  //"O limite para encaixe deve ser um horแrio entre o intervalo das horas inicial e final"###"Atencao"###"valida็ใo dos Campos"
		lRet := .F.
	EndIf
ElseIf ReadVar() == "M->GM6_INTMAR"
	If !FS_VldHA97(M->GM6_INTMAR)
		HS_MsgInf(STR0022, STR0011, STR0053)  //"Intervalo de marca็ใo invแlido"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
	
	If !FS_VLHA97B(M->GM6_HORINI, M->GM6_HORFIM, M->GM6_INTMAR)
		HS_MsgInf(STR0022, STR0011, STR0053)  //"Intervalo de marca็ใo invแlido"###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	EndIf
	
	// Foi definido nao fazer consistencia com o arquivo GM0-Setor X Plano nao atendido, permitindo que se
	// inclua planos para a disponibildade independente do setor. Esta verificacao sera feita pela rotina de
	// marcacao
Elseif ReadVar() == "M->GM4_CODPLA"																			// Valida Disp. x Planos Nao Atendidos
	If !HS_SeekRet("GCM", "M->GM4_CODPLA", 2, .F.,,,,, .T.)
		HS_MsgInf(STR0023, STR0024, STR0053) //"Plano invแlido"###"Verifique"###"Valida็ใo dos Campos"
		lRet := .F.
	Else
		GDFieldPut("GM4_DESPLA", HS_IniPadr("GCM", 2, M->GM4_CODPLA, "GCM_DESPLA",, .F.))
		nPos := aScan(oGM4:aCols, {| aVet | aVet[nGM4_CodPla] == M->GM4_CODPLA})
		If nPos > 0 .And. nPos # oGM4:oBrowse:nAt  // Verifica se este Plano ja foi cadastrado para a disponibilidade
			HS_MsgInf(STR0025, STR0011, STR0053) //"Plano jแ cadastrado para este setor"###"Aten็ใo"###"Valida็ใo dos Campos"
			lRet := .F.
		EndIf
	EndIf
	
ElseIf ReadVar() == "M->GM3_CODPRO"									//Valida Disp. / Procedimentos
	If !HS_SeekRet("GM2", "M->GM6_CODLOC + M->GM3_CODPRO", 1, .F.,,,,, .T.)
		HS_MsgInf(STR0026, STR0011, STR0053) //"Procedimento invแlido ou nใo autorizado para o setor."###"Aten็ใo"###"Valida็ใo dos Campos"
		lRet := .F.
	Else
		GDFieldPut("GM3_DESPRO", HS_IniPadr("GA7", 1, M->GM3_CODPRO, "GA7_DESC",, .F.))
		nPos := aScan(oGM3:aCols, {| aVet | aVet[nGM3_CODPRO] == M->GM3_CODPRO})
		If nPos > 0 .And. nPos # oGM3:oBrowse:nAt  // Verifica se este Plano ja foi cadastrado
			HS_MsgInf(STR0027, STR0011, STR0053) //"Procedimento jแ cadastrado para esta disponibilidade"###"Aten็ใo"###"Valida็ใo dos Campos"
			lRet := .F.
		EndIf
		
	EndIf
	
ElseIf ReadVar() == "M->GM6_CODSAL"
	If Empty(oGO3:aCols[oGO3:nAt, nGO3_CODREC])
		__cCodSal := M->GM6_CODSAL
	ElseIf !(lRet := HS_SeekRet("GF3","M->GM6_CODSAL",1,.f.,"GM6_NOMSAL","GF3_DESCRI")) .Or.  (!Empty(oGO3:aCols[oGO3:nAt, nGO3_CODREC]) .And. !(lRet := HS_SeekRet("GO2","M->GM6_CODSAL+oGO3:aCols[oGO3:nAt, nGO3_CODREC]",1,.F.,,,,, .T.)))
		HS_MsgInf("Sala invแlida", STR0011, STR0053) //Aten็ใo"###"Valida็ใo dos Campos"
	Else
		__cCodSal := M->GM6_CODSAL
	EndIf
ElseIf ReadVar() == "M->GO3_CODREC"
	If !(lRet := HS_SeekRet("GO2","__cCodSal+M->GO3_CODREC",1,.F.,,,,, .T.))
		HS_MsgInf("Recurso nใo cadastrado para sala", STR0011, STR0053) //Aten็ใo"###"Valida็ใo dos Campos"
	Else
		oGO3:aCols[oGO3:nAt, nGO3_DESREC] := HS_IniPadr("GNZ", 1, M->GO3_CODREC, "GNZ_DESREC",, .F.)
	EndIf
ElseIf ReadVar() == "M->GMK_CODREC"
	If !(lRet := HS_SeekRet("GO2","__cCodSal+M->GMK_CODREC",1,.F.,,,,, .T.))
		HS_MsgInf("Recurso nใo cadastrado para sala", STR0011, STR0053) //Aten็ใo"###"Valida็ใo dos Campos"
	ElseIf !(lRet := (nPos := aScan(oGO3:aCols, {|aVet| aVet[nGO3_CODREC] ==  &(ReadVar()) })) > 0 .And. !(oGO3:aCols[nPos, Len(oGO3:aCols[nPos])]))
		HS_MsgInf("Recurso nใo disponivel para disponibilidade", STR0011, STR0053) //Aten็ใo"###"Valida็ใo dos Campos"
	EndIf
EndIf

DbSelectArea(cAliasOld)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldHA97บ Autor ณ Paulo Jose         บ Data ณ  18/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Validacao da hora                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_VldHA97(cCampo)

 Local lRet := .T., cHora := StrTran(cCampo, ":", "")

 If Empty(cHora)
 	lRet := .F.
 Elseif !(SubStr(cHora, 3, 2) >= '00' .And. SubStr(cHora, 3, 2) <= '59')
 	lRet := .F.
 ElseIf !(SubStr(cHora, 1, 2) >= '00' .And. SubStr(cHora, 1, 2) <= '23')
 	lRet := .F.
 ElseIf SubStr(cHora, 1, 2) = '00' .And. SubStr(cHora, 3, 2) = '00'
 	lRet := .F.
 EndIf
 
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldDisp บAutor ณDaniel PEixoto      บ Data ณ  07/20/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Verifica se jแ existe alguma dispon. com os mesmos       บฑฑ
ฑฑบ          ณ  dias para o mesmo medico                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldDisp()

Local lRet       := .T.
Local nForACols  := 0
Local cHorIndisp := ""
Local nLinTGM5   := 0
Local cSqlGm6    := "", cSqlGm5 := ""
Local aArea      := GetArea()

If INCLUI .OR. ALTERA
	cSqlGm6 := "SELECT GM6.GM6_CODCRM, GM6.GM6_CODDIS, GM6.GM6_HORINI, GM6.GM6_HORFIM, GM6.GM6_CODSAL "
	cSqlGm6 += "FROM " + RetSqlName("GM6") + " GM6 "
	cSqlGm6 += "WHERE GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' "
	cSqlGm6 += "AND GM6.GM6_CODCRM = '" + M->GM6_CODCRM + "' AND GM6.GM6_CODDIS <> '" + M->GM6_CODDIS + "' "
	cSqlGm6 += "AND GM6.GM6_IDEATI = '1'"
	cSqlGm6 := ChangeQuery(cSqlGm6)
	
	TCQuery cSqlGm6 New Alias "GM6CRM"
	DbSelectArea("GM6CRM")
	While !Eof() .And. lRet //dispnibilidade
		
		cSqlGm5 := "SELECT GM5.GM5_CODDIS, GM5.GM5_DIASEM "
		cSqlGm5 += "FROM " + RetSqlName("GM5") + " GM5 "
		cSqlGm5 += "WHERE GM5.D_E_L_E_T_ <> '*' AND GM5.GM5_FILIAL = '" + xFilial("GM5") + "' "
		cSqlGm5 += "AND GM5.GM5_CODDIS = '" + GM6CRM->GM6_CODDIS + "' "
		cSqlGm5 := ChangeQuery(cSqlGm5)
		
		TCQuery cSqlGm5 New Alias "GM5DIS"
		
		DbSelectArea("GM5DIS")
		While !Eof() .And. lRet //Disp X Dias semana
			nLinTGM5 := IIf(Len(oGM5:aCols) == 1 .And. Empty(oGM5:aCols[1, nGM5_DIASEM]), 0, Len(oGM5:aCols) )
			
			For nForACols := 1 To nLinTGM5
				If GM5DIS->GM5_CODDIS == GM6CRM->GM6_CODDIS .And. GM5DIS->GM5_DIASEM == oGM5:aCols[nForACols, nGM5_DIASEM] .And. !oGM5:aCols[nForACols, nUGM5 + 1]
					If M->GM6_HORINI >= GM6CRM->GM6_HORINI .And. M->GM6_HORINI <= GM6CRM->GM6_HORFIM .Or. M->GM6_HORFIM >= GM6CRM->GM6_HORINI .And. M->GM6_HORFIM <= GM6CRM->GM6_HORFIM
						HS_MsgInf(STR0039 + FS_DiaExt(oGM5:aCols[nForACols, nGM5_DIASEM]) + STR0040 + GM6CRM->GM6_HORINI + STR0041 + GM6CRM->GM6_HORFIM, STR0011, STR0054) //"Jแ Existe Disponibilidade Cadastrada no dia "###" para esse M้dico no perํodo das "###" a "###"Aten็ใo"###"Verifica็ใo de Disponibilidade"
						lRet:= .F.
					ElseIf M->GM6_HORINI < GM6CRM->GM6_HORINI .And. M->GM6_HORFIM >= GM6CRM->GM6_HORINI
						HS_MsgInf(STR0042 + FS_DiaExt(oGM5:aCols[nForACols, nGM5_DIASEM]) + STR0043, STR0011, STR0054) //"Horแrio Final Incompatํvel, Jแ Existe Disponibilidade Cadastrada no dia "###" para esse M้dico"###"Aten็ใo"###"Verifica็ใo de Disponibilidade"
						lRet:= .F.
					ElseIf !Empty(M->GM6_CODSAL) .And. M->GM6_CODSAL == GM6CRM->GM6_CODSAL //valida a sala para o medico em questao
						cHorIndisp := HS_SomaHor(GM6CRM->GM6_HORFIM, HS_IniPadr("GF3", 1, M->GM6_CODSAL, "GF3_INTERV",, .F.)) //Hor de intervalo da sala GF3_Interv
						If M->GM6_HORINI > GM6CRM->GM6_HORFIM .And. M->GM6_HORINI <= cHorIndisp
							HS_MsgInf(STR0044 + cHorIndisp, STR0011, STR0054) //"Horแrio Inicial Incompatํvel, Sala Indisponํvel at้ "###"Aten็ใo"###"Verifica็ใo de Disponibilidade"
							lRet:= .F.
						EndIf
					EndIf
				EndIf
			Next
			
			DBSkip()
		EndDo
		
		DbSelectArea("GM5DIS")
		DbCloseArea()
		
		DbSelectArea("GM6CRM")
		DbSkip()
	EndDo
	
	DbSelectArea("GM6CRM")
	DbCloseArea()
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DiaExt บAutor  ณDaniel Peixoto      บ Data ณ  07/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o dia por extenso correspondente ao Memo           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_DiaExt(cNroDia)

 Local cDia := ""
  
 If cNroDia == "1"
  cDia := STR0045 //"Domingo"
 ElseIF  cNroDia == "2"
  cDia := STR0046 //"Segunda"
 ElseIF  cNroDia == "3"
  cDia := STR0047 //"Ter็a"
	ElseIF  cNroDia == "4"
  cDia := STR0048 //"Quarta"
	ElseIF  cNroDia == "5"
  cDia := STR0049 //"Quinta"
	ElseIF  cNroDia == "6"
  cDia := STR0050 //"Sexta"
	ElseIF  cNroDia == "7"
  cDia := STR0051 //"Sแbado"
 EndIf  
     
Return(cDia)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_SOMAHORบ Autor ณDaniel Peixoto      บ Data ณ  07/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Soma duas horas no formato 99:99                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_SOMAHOR(cHora1, cHora2)

 Local cRet  	:= ""
 Local nHora1 := Val(StrTran(cHora1, ":", "."))
 Local nHora2 := Val(StrTran(cHora2, ":", "."))
 Local nHoras := 0
 Local cHoras :=""
 Local cMin	  :=""
 
 nHoras	:= somahoras(nHora1, nHora2)
 cHoras	:= StrZero(int(nHoras), 2)
 cMin	  := PADR(STUFF(ALLTRIM(STR(nHoras-int(nHoras))), 1, 2, ""), 2, "0")
 cRet	  := cHoras + ":" + cMin
 
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA97 บ Autor ณ Paulo Jose         บ Data ณ  18/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Atualizacao das tabelas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvA97(nOpc)

 Local wProcura := .F.    

 aCGM5 := aClone(oGM5:aCols)
 aCGM4 := aClone(oGM4:aCols)
 aCGM3 := aClone(oGM3:aCols)
 aCGMK := aClone(oGMK:aCols)
 aCGO3 := aClone(oGO3:aCols)

 If nOpc # 2 // nao for consulta
 	DbSelectArea("GM6")
 	DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
 	wProcura := DbSeek(xFilial("GM6") + M->GM6_CODDIS)
 	If Inclui .Or. Altera
 
	  //GRAVA CADASTRO LOCAL DE ATENDIMENTO - GCS
	  RecLock("GM6", If(Altera, .F., .T.))
	  HS_GRVCPO("GM6")
	  MsUnlock()
	  ConfirmSx8()
				
	  FS_GrvGM("GM5", 1, "M->GM6_CODDIS + aCGM5[pForACols, nGM5_DIASEM]", aHGM5, aCGM5, nUGM5,nGM5_DIASEM,.F.)
	  FS_GrvGM("GM4", 1, "M->GM6_CODDIS + aCGM4[pForACols, nGM4_CODPLA]", aHGM4, aCGM4, nUGM4,nGM4_CODPLA,.T.)
	  FS_GrvGM("GM3", 1, "M->GM6_CODDIS + aCGM3[pForACols, nGM3_CODPRO]", aHGM3, aCGM3, nUGM3,nGM3_CODPRO,.T.)
	  FS_GrvGM("GMK", 2, "M->GM6_CODDIS + aCGMK[pForACols, nGMK_ITEDIA]", aHGMK, aCGMK, nUGMK,nGMK_DIASEM,.F.)
	  FS_GrvGM("GO3", 1, "M->GM6_CODDIS + M->GM6_CODSAL + aCGO3[pForACols, nGO3_CODREC]", aHGO3, aCGO3, nUGO3,nGO3_CODREC,.F.)
		
	 Else  // exclusao
		 If wProcura
		 	If !FS_VldExcD()
			 	HS_MsgInf(STR0037, STR0011, STR0055) //"Existe agenda gerada para esta disponbiliddade. Exclusใo nใo permitida."###"Aten็ใo"###"Atualiza็ใo"
			 	lRet := .F.
			 Else
			 	// DELETA relacionamentos GM5
			 	FS_DelGM("GM5", 1, "M->GM6_CODDIS + aCGM5[pForACols, nGM5_DIASEM]", aCGM5,nGM5_DIASEM)
			 	FS_DelGM("GM4", 1, "M->GM6_CODDIS + aCGM4[pForACols, nGM4_CODPLA]", aCGM4,nGM4_CODPLA)
			 	FS_DelGM("GM3", 1, "M->GM6_CODDIS + aCGM3[pForACols, nGM3_CODPRO]", aCGM3,nGM3_CODPRO)
			 	FS_DelGM("GMK", 2, "M->GM6_CODDIS + aCGMK[pForACols, nGMK_ITEDIA]", aCGMK,nGMK_DIASEM)
	    		FS_DelGM("GO3", 1, "M->GM6_CODDIS + M->GM6_CODSAL + aCGO3[pForACols, nGO3_CODREC]", aCGO3, nGO3_CODREC)
				
			 	DbSelectArea("GM6")
			 	RecLock("GM6", .F., .T.)
			 	DBDelete()
			 	MsUnlock()
			 	WriteSx2("GM6")
			 EndIf
		 EndIf
	 EndIf
 EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGM  บ Autor ณ Paulo Jose         บ Data ณ  18/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento - GM0, GM1 e GM2          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGM(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv, nPos, lLocal)

 Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
 Local cPref := cAlias + "->" + PrefixoCpo(cAlias)

 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]) )     // Se aCols nao vazio
	 For nForACols := 1 To Len(aCGrv)
	 	pForACols := nForACols
		
		 DbSelectArea(cAlias)
		 DbSetOrder(nOrd)
		 lAchou := DbSeek(xFilial(cAlias) + &(cChave))
		 If aCGrv[nForACols, nUGrv + 1] .And. lAchou // exclusao
		 	RecLock(cAlias, .F., .T.)
		 	DbDelete()
		 	MsUnlock()
		 	WriteSx2(cAlias)
		 Else
		 	If !aCGrv[nForACols, nUGrv + 1]
		 		RecLock(cAlias, !lAchou)
		 		HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
		 		&(cPref + "_FILIAL") := xFilial(cAlias)
		 		&(cPref + "_CODDIS") := M->GM6_CODDIS
		 		If lLocal     //lLocal refere-se a dizer se o arquivo tem o atributo CODLOC ou nao
		 			&(cPref + "_CODLOC") := M->GM6_CODLOC
		 		EndIf
		 		&(cPref + "_IDEATI") := M->GM6_IDEATI
		 		&(cPref + "_LOGARQ") := HS_LogArq()
		 		
		 		If cAlias == "GM4"
		 			&(cPref + "_CODCON") := HS_IniPadr("GCM", 2, aCGrv[nForACols, nGM4_CODPLA], "GCM_CODCON",, .F.)
		   ElseIf cAlias == "GO3"
		 			&(cPref + "_CODSAL") := M->GM6_CODSAL
		 		EndIf
		 		
		 		MsUnlock()
		 	EndIf
		 EndIf
	 Next
 EndIf

 DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DelGM  บ Autor ณ Paulo Jose         บ Data ณ  18/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de DELETE dos relacionamentos do Local              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DelGM(cAlias, nOrd, cChave, aCGrv,nPos)

 Local nForDel := 0, cAliasOld := Alias()

 If !(len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]) )     // Se aCols nao vazio
 	For nForDel := 1 To Len(aCGrv)
 		pForACols  := nForDel
 		
 		DbSelectArea(cAlias)
 		DbSetOrder(nOrd)
 		If DbSeek(xFilial(cAlias) + &(cChave))
 			RecLock(cAlias, .F., .T.)
 			DbDelete()
 			MsUnlock()
 			WriteSx2(cAlias)
 		EndIf
 	Next
 EndIf
 DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldExcDบ Autor ณ Paulo Jose         บ Data ณ  07/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina que Verifica se a disponibilidade esta em           บฑฑ
ฑฑบ          ณ uso na Agenda Ambulatorial (GM8)                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldExcD()

 Local aArea := GetArea()
 Local lRet  := .T.

 DbSelectArea("GM8")
 DbSetOrder(9) // GM8_FILIAL + GM8_CODDIS 
 lRet := !DbSeek(xFilial("GM8") + M->GM6_CODDIS)

 RestArea(aArea)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldExcRบ Autor ณ Sueli Santos       บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina que Verifica se o Recurso esta em                   บฑฑ
ฑฑบ          ณ uso na Agenda Ambulatorial (GM8)                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldExcR(cCodRec)

 Local lRetGm8       := .F.
 Local cSqlGm8    := ""
 Local aArea      := GetArea()
 Default cCodRec := ""
 
  cSqlGm8 := "SELECT GM8.GM8_CODDIS, GM8.GM8_DATAGE, GM8.GM8_STATUS "
  cSqlGm8 += "FROM " + RetSqlName("GM8") + " GM8 "
  cSqlGm8 += "WHERE GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' "
  cSqlGm8 += "AND GM8.GM8_CODDIS = '" + M->GM6_CODDIS + "' AND GM8.GM8_CODSAL = '" + M->GM6_CODSAL + "' "
  cSqlGm8 += "AND GM8.GM8_CODREC = '" + cCodRec + "' "
  cSqlGm8 += "AND GM8.GM8_DATAGE >= '" + DTOS(DDATABASE) + "'"
  cSqlGm8 := ChangeQuery(cSqlGm8)
 
  TCQuery cSqlGm8 New Alias "TMPGM8"
 	DbSelectArea("TMPGM8")
	 If !Eof()  
	    lRetGm8 := .T. 
     EndIf

 DbCloseArea()  
 RestArea(aArea)
Return(lRetGm8)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FACILI บ Autor ณ Cibele Peria       บ Data ณ  24/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Prepara Facilitadores                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FACILI()

 If oFolder:nOption == 1
 	HS_MsgInf(STR0031, STR0011, STR0056) //"Facilitador nใo gerado para este relacionamento"###"Aten็ใo"###"Prepara Facilitadores"
 Else
 	If Empty(M->GM6_CODDIS)
 		HS_MsgInf(STR0029, STR0011, STR0056) //"Por Favor,informe o c๓digo da disponibilidade"###"Aten็ใo"###"Prepara Facilitadores"
 	Else
 		If oFolder:nOption == 2
 			PROCESSA({||FS_FACPLA()})
 		ElseIF oFolder:nOption == 3
 			If Empty(M->GM6_CODLOC)
 				HS_MsgInf(STR0032, STR0011, STR0056)//"Por favor, informe o c๓digo do setor"###"Aten็ใo"###"Prepara Facilitadores"
 			Else
 				PROCESSA({||FS_FACPRO()})
 			EndIf
 		EndIf
 	EndIf
 EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FACPLA บ Autor ณ Cibele Peria       บ Data ณ  24/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Facilitador para inclusao de planos no relacionamento      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FACPLA()

 Local aArea := GetArea(), lRet := .T., nForACols := 0

 aCGM4 := aClone(oGM4:aCols)

 For nForACols := 1 To Len(aCGM4)
 	If aCGM4[nForACols, nUGM4 + 1] == .T.
 		HS_MsgInf(STR0033, STR0011, STR0057) //"Atualize a disponibilidade (relacionamentos excluํdos) antes de executar o facilitador"###"Aten็ใo"###"Facilitador para Inclusใo de Planos no Relacionamento"
 		lRet := .F.
 		Exit
 	EndIf
 Next

 If lRet
 	If Pergunte("HSA97A", .T.)
 		DbSelectArea("GCM") //Cadastro de Planos X Convenios
 		DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
 		ProcRegua(RecCount())
 		DbSeek(xFilial("GCM") + MV_PAR01, .T.)
 		
 		While !Eof() .And. GCM->GCM_FILIAL == xFilial("GCM") .And. GCM->GCM_CODPLA <= MV_PAR02
 			IncProc(STR0030 + GCM->GCM_CODPLA) //"Processando... "
 			
 			If Empty(aCGM4[oGM4:nAt, nGM4_CODPLA])
 				aCGM4[oGM4:nAt, nGM4_CODPLA] := GCM->GCM_CODPLA
 				aCGM4[oGM4:nAt, nGM4_DESPLA] := GCM->GCM_DESPLA
 				aCGM4[oGM4:nAt, nUGM4 + 1]   := .F.
 			ElseIf aScan(oGM4:aCols, {| aVet | aVet[1] == GCM_CODPLA})	== 0
 				aADD(aCGM4, oGM4:aCols[1])
 				aCGM4[Len(aCGM4), nGM4_CODPLA] := GCM->GCM_CODPLA
 				aCGM4[Len(aCGM4), nGM4_DESPLA] := GCM->GCM_DESPLA
 			EndIf
 			oGM4:SetArray(aCGM4)
 			DbSkip()
 		EndDo
		
 		oGM4:Refresh()
 	EndIf
 EndIf

 RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FACPLA บ Autor ณ Cibele Peria       บ Data ณ  27/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Facilitador P/incluisao de procedimentos no relacionamento บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FACPRO()

 Local aArea := GetArea(), lRet := .T., nForACols := 0

 aCGM3 := aClone(oGM3:aCols)

 For nForACols := 1 To Len(aCGM3)
 	If aCGM3[nForACols, nUGM3 + 1] == .T.
 		HS_MsgInf(STR0033, STR0011, STR0058) //"Atualize a disponibilidade (relacionamentos excluํdos) antes de executar o facilitador"###"Aten็ใo"###"Facilitador para Inclusใo de Procedimentos no Relacionamento"
 		lRet := .F.
 		Exit
 	EndIf
 Next

 If lRet
 	If Pergunte("HSP99B", .T.)
 		DbSelectArea("GM2") //Cadastro de Procedimentos
 		DbSetOrder(1) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
 		ProcRegua(RecCount())
 		DbSeek(xFilial("GM2") + M->GM6_CODLOC + MV_PAR01, .T.)
 		While !Eof() .And. GM2->GM2_FILIAL == xFilial("GM2") .And. GM2->GM2_CODLOC == M->GM6_CODLOC .And. GM2->GM2_CODPRO <= MV_PAR02
			 IncProc(STR0030 + GM2->GM2_CODPRO) //"Processando... "
			
			 DbSelectArea("GA7")
			 DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
			 If DbSeek(xFilial("GA7") + GM2->GM2_CODPRO)
			 	If GA7->GA7_CODGPP >= MV_PAR03 .And. GA7->GA7_CODGPP <= MV_PAR04 //Consiste Grupo de Procedimento
			 		If GA7->GA7_CODGDE >= MV_PAR05 .And. GA7->GA7_CODGDE <= MV_PAR06 //Consiste Grupo de Despesa
			 			If GA7->GA7_CODESP >= MV_PAR07 .And. GA7->GA7_CODESP <= MV_PAR08 //Consiste eSPECIALIDADE
			 				
			 				If Empty(aCGM3[oGM3:nAt, nGM3_CODPRO])
			 					aCGM3[oGM3:nAt, nGM3_CODPRO] := GA7->GA7_CODPRO
			 					aCGM3[oGM3:nAt, nGM3_DESPRO] := GA7->GA7_DESC
			 					aCGM3[oGM3:nAt, nUGM3 + 1] := .F.
			 				ElseIf aScan(aCGM3, {| aVet | aVet[1] == GA7_CODPRO})	== 0
				 				aADD(aCGM3, oGM3:aCols[1])
				 				aCGM3[Len(aCGM3), nGM3_CODPRO] := GA7->GA7_CODPRO
				 				aCGM3[Len(aCGM3), nGM3_DESPRO] := GA7->GA7_DESC
				 			EndIf
				 			oGM3:SetArray(aCGM3)
							
				 		EndIf
				 	EndIf
				 EndIf
			 EndIf
			 DbSelectArea("GM2")
			 DbSkip()
		 End
		
		 oGM3:Refresh()
	 EndIf
 EndIf

 RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VlHA97BบAutor  ณAlessandro Freire   บ Data ณ  23/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o intervalo maximo entre uma hora e outra           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                              
Static Function FS_VlHA97B(cHoraI, cHoraF, cHoraM) 

 Local nHoraInter := 0, cHoraInter := StrTran(cHoraM, ":", "")
 
 nHoraInter := Val(SubStr(cHoraInter, 1, 2)) + (Val(SubStr(cHoraInter, 3, 2)) / 60)

Return( nHoraInter <= SubtHoras(dDataBase, cHoraI, dDataBase, cHoraF))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSVLCOLS  บAutor  ณAlessandro Freire   บ Data ณ  23/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ valida se o dia da semana e o procedimento estao           บฑฑ
ฑฑบ          ณ preenchidos                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VLCols(oCGM5, oCGM3, oCGO3, nOpc)

 Local lRet1 := .F.
 Local lRet2	:= .F.
 Local lRet3	:= .T.
 Local lRet4	:= .F.
 Local nI		:= 0
 Local cMsgErro := ""
 
 If nOpc < 3 .Or. nOpc > 4
 	Return(.T.)
 EndIf

 For nI := 1 To Len(oGM5:aCols)
 	If ! Empty(oGm5:aCols[nI, nGM5_DIASEM]) .And. !oGM5:aCols[ni, Len(oGm5:aCols[ni])]
 		lRet1 := .T.
 		Exit
 	EndIf
 Next nI

 If !lRet1
 	HS_MsgInf(STR0035, STR0011, STR0053) //"Pelo menos um dia da semana deve ser incluํdo"###"Aten็ใo"###"Valida็ใo dos Campos"
 EndIf

 For nI := 1 To Len(oGm3:aCols)
 	If !Empty(oGm3:aCols[nI, nGM3_CODPRO]) .And. !oGm3:aCols[ni, Len(oGm3:aCols[ni])]
 		lRet2 := .T.
 		Exit
 	EndIf
 Next nI

 If !lRet2
 	HS_MsgInf(STR0036, STR0011, STR0053) //"Pelo menos um procedimento deve ser incluํdo"###"Aten็ใo"###"Valida็ใo dos Campos"
 EndIf

 //Valida a exlusao do Recurso
 For nI := 1 To Len(oGo3:aCols)
 	If oGo3:aCols[nI, Len(oGo3:aCols[nI])]  
 		If FS_VldExcR(oGo3:aCols[nI, nGO3_CODREC])
 	 		 cMsgErro += STR0070 + " " + oGo3:aCols[nI, nGO3_CODREC] + ". " + STR0071 + chr(10) //""###" Existe horario gerado para o Recurso
			 lRet3 := .F. 
 		EndIf
	EndIf
	If lDicStatu
		If 	Empty(M->GM6_CODSAL)   
			lRet4:=.T. 
		Else	
			If !Empty(oGo3:aCols[nI, nGO3_CODREC])
				If  oGo3:aCols[nI, nGO3_STATUS] == "0"
					lRet4 := .T.
					Exit
				Endif	
			Endif	
		
		Endif		
	Else
		lRet4:=.T. 	
	Endif	
	
 Next nI  
 
  If !lRet4
 	HS_MsgInf(STR0072, STR0011, STR0053) //"Pelo menos um procedimento deve ser incluํdo"###"Aten็ใo"###"Valida็ใo dos Campos"
 EndIf  

 If !Empty(cMsgErro)
	 HS_MsgInf(cMsgErro, STR0011, STR0055) //"Existe agenda gerada para este Recurso. Exclusใo nใo permitida."###"Aten็ใo"###"Atualiza็ใo"
 EndIf
  
  
Return(lRet1 .And. lRet2 .And. lRet3 .And. lRet4)


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
Local aRotina :=	{{OemtoAnsi(STR0001 ), "axPesqui", 0, 1, 0, nil}, ;  //"Pesquisar"
                     {OemtoAnsi(STR0002 ), "HS_A97"  , 0, 2, 0, nil}, ;  //"Visualizar"
                     {OemtoAnsi(STR0003 ), "HS_A97"  , 0, 3, 0, nil}, ;  //"Incluir"
                     {OemtoAnsi(STR0004 ), "HS_A97"  , 0, 4, 0, nil}, ;  //"Alterar"
                     {OemtoAnsi(STR0005 ), "HS_A97"  , 0, 5, 0, nil}}    //"Excluir"
Return(aRotina)


Static Function FS_VLDGMK(oGMK,nDIASEM,nHORINI,nHORFIM, nCODREC)
Local lRet := .T., nLinTGMK := 0,nForACols := 0, nForVer := 0

nLinTGMK := IIf(Len(oGMK:aCols) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(oGMK:aCols))
For nForACols := 1 To nLinTGMK
	If !Empty(M->GM6_CODSAL) .AND. Empty(oGMK:aCols[nForACols, nCODREC])
		HS_MsgInf("Obrigatorio indica็ใo do recurso (Periodos Indisponiveis)!", STR0011, STR0053) //"Perํodo coincidente com os perํodos jแ cadastrados para esse dia"###"Aten็ใo"###"Valida็ใo dos Campos"			
		lRet := .F.
		Exit
	EndIf
	
	For nForVer := 1 To nLinTGMK
		If nForVer <> nForAcols .AND. ;
			oGMK:aCols[nForACols, nDIASEM] == oGMK:aCols[nForVer, nDIASEM] .AND. ;
			oGMK:aCols[nForACols, nCODREC] == oGMK:aCols[nForVer, nCODREC] .AND. ;			
			(oGMK:aCols[nForACols, nHORFIM] <= oGMK:aCols[nForVer, nHORFIM] ; 
			.And. oGMK:aCols[nForACols, nHORFIM] >= oGMK:aCols[nForVer, nHORINI] .Or. ;
			oGMK:aCols[nForACols, nHORFIM] > oGMK:aCols[nForVer, nHORINI] ;
			.And. oGMK:aCols[nForACols, nHORINI] <= oGMK:aCols[nForVer, nHORFIM]) .AND. ;						
			!oGMK:aCols[nForACols, nUGMK + 1] .AND. ;
			!oGMK:aCols[nForVer, nUGMK + 1]

			HS_MsgInf(STR0064, STR0011, STR0053) //"Perํodo coincidente com os perํodos jแ cadastrados para esse dia"###"Aten็ใo"###"Valida็ใo dos Campos"
			lRet := .F.
			Exit
		EndIf   

	Next nForVer 
	If !lRet
		Exit
	EndIf
Next nForACols

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldRange  บAutor  ณMicrosiga          บ Data ณ  10/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao para validar se os horarios indisponiveis (inicial  บฑฑ
ฑฑบ          ณ e final) sใo iguais.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldRange()
Local lRet := .T.
nPosHIni := aScan(oGMK:aHeader, {| X | X[2] == "GMK_HORINI"})

If oGMK:aCols[oGMK:oBrowse:nAt][nPosHIni] == M->GMK_HORFIN 
	MsgAlert("O Horแrio incial indisponํvel ้ igual ao horแrio final, o sistema nใo irแ considerar este perํodo!")
EndIf	

Return lRet