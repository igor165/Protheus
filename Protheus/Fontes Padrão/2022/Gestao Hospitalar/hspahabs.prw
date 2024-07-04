#Include "Protheus.ch"

Function HSPAHABS()

Private aRotina :=	{	{OemToAnsi("Pesquisar") ,	"AxPesqui",	0, 1},; //"Pesquisar"
						{OemToAnsi("Visualizar"),	"HS_Rot"  ,	0, 2},; //"Visualizar"
						{OemToAnsi("Incluir")   ,	"HS_Rot"  ,	0, 3},; //"Incluir"
						{OemToAnsi("Alterar")   ,	"HS_Rot"  ,	0, 4},; //"Alterar"
						{OemToAnsi("Excluir")   ,	"HS_Rot"  ,	0, 5}} //"Excluir"

Private cCadastro := OemToAnsi("Cadastro Ítens do Layout")


DbSelectArea("GG1")
DbSelectArea("GG0")
DbSetOrder(1)
mBrowse( 6, 1, 22, 75,"GG0",,,,,,)

Return()

Function HS_Rot(cAlias, nReg, nOpc)

Local nOpcG		:= aRotina[nOpc, 4]
Local nOpA		:= 0
Local nGDOpc	:= IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local nLenGD	:= 0
Local aCposGG0	:= {}
Local aMemoGG0	:= {}
Local aFolder	:= {}
Local nCont		:= 0

Private aTela := {}, aGets := {}
Private aHGG1 := {}, aCGG1 := {}, nUGG1 := 0
Private oDlg, oGG1, oEnchoi
Private nGG1Item := 0

RegToMemory("GG0", (nOpcG == 3))
DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("GG0")
	While !SX3->(EoF()) .And. SX3->X3_ARQUIVO == "GG0"
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If X3_TIPO == "M" .And. X3_PROPRI # "U"
				_SetOwnerPrvt("o"+X3_CAMPO)
				aAdd(aMemoGG0, {X3_CAMPO, X3_TITULO, X3_VALID, X3_FOLDER, X3_WHEN, "o"+X3_CAMPO})
			Else
				aAdd(aCposGG0, X3_CAMPO)
			EndIf
		EndIF
		DbSkip()
	End
EndIf

aAdd(aFolder, "Dados Gerais")
For nCont := 1 to Len(aMemoGG0)
	aAdd(aFolder, aMemoGG0[nCont, 2])
Next


HS_BDados("GG1", @aHGG1, @aCGG1, @nUGG1, 1,, IIf((nOpcG == 3), Nil, "GG1->GG1_CODGRU == '" + M->GG0_CODGRU + "'"))

nGG1Item   := aScan(aHGG1, {| aVet | AllTrim(aVet[2]) == "GG1_ITEM"})
nGG1OrdCam := aScan(aHGG1, {| aVet | AllTrim(aVet[2]) == "GG1_ORDCAM"})
nGG1FunExp := aScan(aHGG1, {| aVet | AllTrim(aVet[2]) == "GG1_FUNEXP"})

If Empty(aCGG1[1, nGG1Item])
	aCGG1[1, nGG1Item] := StrZero(1, Len(GG1->GG1_ITEM))
EndIf

aSize 			:= MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 040, .T., .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Cadastro Ítens do Layout") From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd

oFolEnc := TFolder():New( aPObjs[1, 1],  aPObjs[1, 2], aFolder, aFolder, oDlg,,,, .T., , aPObjs[1, 3], aPObjs[1, 4] )
oFolEnc:Align := CONTROL_ALIGN_TOP

oEnchoi := MsMGet():New("GG0",nReg,nOpc, , , ,aCposGG0,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oFolEnc:aDialogs[1])
oEnchoi:oBox:align:= CONTROL_ALIGN_ALLCLIENT

For nCont := 1 to Len(aMemoGG0)
	&(aMemoGG0[nCont, 6]) := &("tMultiget():New("+AllTrim(str(aPObjs[1, 1]))+","+AllTrim(str(aPObjs[1, 2]))+",{|u|if(Pcount()>0,M->"+aMemoGG0[nCont, 1]+":=u,M->"+aMemoGG0[nCont, 1]+")},oFolEnc:aDialogs["+AllTrim(Str(nCont+1))+"],"+AllTrim(str(aPObjs[1, 3]))+","+AllTrim(str(aPObjs[1, 4]))+",,,,,,.T.)")
	&(aMemoGG0[nCont, 6]):Align := CONTROL_ALIGN_ALLCLIENT
Next

oGG1 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,"+GG1_ITEM",,, 99999,,,, oDlg, aHGG1, aCGG1)
oGG1:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGG1:bLinhaOk := {|| HS_DuplAC(oGG1:oBrowse:nAt, oGG1:aCols, {nGG1OrdCam})}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {	|| nOpA := 1,;
IIF(Obrigatorio(aGets, aTela) .And. oGG1:TudoOk(), oDlg:End(), nOpA := 0)},;
{|| nOpA := 0, oDlg:End()})


If (nOpA == 1) .And. (nOpcG <> 2)
	Begin Transaction
	FS_GrvStr(nOpcG, oGG1)
	While __lSx8
		ConfirmSx8()
	End
	End Transaction
	
ElseIf nOpcG <>2
	While __lSx8
		RollBackSxe()
	End
Endif

Return()

Function FS_GrvStr(nOpcG, oGet)
Local lAchou := .T.
Local nFor   := 0

DbselectArea("GG0")
DbsetOrder(1) //GG0_FILIAL+GG0_CODGRU
lAchou := DbSeek(xFilial("GG0") + M->GG0_CODGRU)

If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
	RecLock("GG0", !lAchou)
	HS_GRVCPO("GG0")
	GG0->GG0_FILIAL  := xFilial("GG0")
	MsUnlock()
	
	DbSelectArea("GG1")
	DbSetOrder(1)//GG1_FILIAL+GG1_CODGRU+GG1_ITEM
	
	For nFor :=1 To Len(oGet:aCols)
		lAchou := DbSeek(xFilial("GG1") + M->GG0_CODGRU + oGet:aCols[nFor, nGG1Item] )
		If oGet:aCols[nFor, Len(oGet:aHeader)+1 ]== .T.  // Se a linha esta deletada na get e achou o kra no banco
			If lAchou .And. nOpcG <> 3
				RecLock("GG1", .F., .F. )
				DbDelete()
				MsUnlock()
				WriteSx2("GG1")
			EndIf
		Else
			RecLock("GG1", !lAchou )
			HS_GRVCPO("GG1", oGet:aCols, oGet:aHeader, nFor)
			GG1->GG1_FILIAL := xFilial("GG1")
			GG1->GG1_CODGRU := M->GG0_CODGRU
			GG1->GG1_SEGMEN := M->GG0_SEGMEN
			MsUnlock()
		EndIf
	Next
	
Else // EXCLUSAO
	
	DbSelectArea("GG1")
	DbSetOrder(1)//GG1_FILIAL+GG1_CODGRU+GG1_ITEM
	DbSeek(xFilial("GG1") + M->GG0_CODGRU)
	While !Eof() .And. GG1->GG1_FILIAL = xFilial("GG1") .And. GG1->GG1_CODGRU = M->GG0_CODGRU
		RecLock("GG1", .F., .F. )
		DbDelete()
		MsUnlock()
		WriteSx2("GG1")
		DbSkip()
	End
	
	RecLock("GG0", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("GG0")
Endif

Return()

