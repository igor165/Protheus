#INCLUDE "HSPAHM12.ch"
#include "protheus.CH"
#include "colors.CH"
#include "TopConn.ch"
#INCLUDE "Report.ch"

Static __RetStatus := ""

/*/.
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM12  º Autor ³ Bruno Santos       º Data ³  17/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Solicitação APAC                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM12()

Local aCorM12 := {{"GK7->GK7_STATUS == '0' " , "BR_VERDE"},;
{"GK7->GK7_STATUS == '1' " , "BR_AMARELO"},;
{"GK7->GK7_STATUS == '2' " , "BR_AZUL"},;
{"GK7->GK7_STATUS == '3' " , "BR_LARANJA"},;
{"GK7->GK7_STATUS == '4' " , "BR_VERMELHO"},;
{"GK7->GK7_STATUS == '5' " , "BR_CINZA"}}
Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM12(.T.)})

Private aRotina    := MenuDef()
Private __cProntu  := ""  //Utilizado Filtro GCY
Private __cGStatus := "0" //Utilizado Filtro GCY
Private cSusProIns := "06/07"//Utilizado Filtro GA7
Private cCadastro  := "Solicitação APAC"
Private cGBJTipPro := ""
Private cFilM12    := ""
Private cCodProSus := "" //Utilizado Filtro GAS
Private cGcsTipLoc := "5"

AjustaSXB()
If !Hs_ExisDic({{"T", "GK7"}})
	Return(Nil)
EndIf

If Hs_ExisDic({{"C","GK7_SEQAGE"}},.F.)
	aAdd(aRotina, {"Agendar"  ,"HS_M12AGD", 0, 4, 0, nil})
EndIf

DbSelectArea("GK8")
DbSelectArea("GK7")
DbSetOrder(1)

If FS_FilM12(.F.)
	mBrowse(06, 01, 22, 75, "GK7", , , , , , aCorM12,,,,,,,, cFilM12)
EndIf

SetKey(VK_F12, bKeyF12)

Return(nil)

Function Hs_M12ROT(cAlias, nReg, nOpc)
Local aSvKeys		:= GetKeys()
Local nI       := 0
Local cOldVar  := ""
Local aButtons := {}
Local aCpos    := {}
Local lDevApac := IIF(Type("lDevolve") # "U",lDevolve, .F.)
Local nOpcGd   := IIF(nOpc == 3 .Or. nOpc == 4, GD_INSERT+GD_UPDATE+GD_DELETE, 0)

Private oEnGK7, oEnGK8
Private aTela   := {}, aGets := {}, aSTela := {{},{}}, aSGets := {{},{}}
Private cTab := "", aPGets := {}
Private cTabSel := ""
Private nOpcDlg := 0
Private aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Private aTelaQues := {}
Private aMntperg := {}
Private oPnlGk8
Private nOpcE   := aRotina[nOpc, 4]
Private cCdQues := GK7->GK7_CDQUES
//Variaveis Pedido de Compra MATA120
PRIVATE aBackSC7   := {}
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}
PRIVATE bFiltraBrw := {|| Nil }
PRIVATE l120Auto   := .F.
PRIVATE nTipoPed   := 1
PRIVATE lGatilha   := .T.
PRIVATE lVldHead   := GetNewPar( "MV_VLDHEAD",.T. )// O parametro MV_VLDHEAD e' usado para validar ou nao o aCols (uma linha ou todo), a partir das validacoes do aHeader -> VldHead()
Private LEDTCODLOC := .T.
Private nGKACODITE := 0
Private nGKACODPRO := 0
Private nGKADESPRO := 0
Private aHGKA := {}, aCGKA := {}, nUGKA := 0, oGKA := nil

If( Empty(cCdQues) .Or. nOpcE == 3)
	If Empty(cCdQues := Fs_RetQues())
		Return(Nil)
	EndIf
endif

aSize 			:= MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
aAdd( aObjects, { 100, 100, .T., .T.} )

aInfo  := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGets := MsObjSize( aInfo, aObjects, .T., .T., .T.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GK7")
While SX3->(!Eof()) .And. X3_ARQUIVO == "GK7"
	If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. (!SX3->X3_CAMPO $ "GK7_CODMOT/GK7_DESMOT" .Or. lDevApac)
		Aadd(aCpos, SX3->X3_CAMPO)
	EndIf
	DbSkip()
EndDo

RegToMemory("GK7", nOpcE == 3)
M->GK7_CDQUES := cCdQues
HS_SeekRet("GFS", "M->GK7_CDQUES", 1, .F., "GK7_DSQUES", "GFS_DSQUES",,, .T.)

If nOpcE # 2 .And. (M->GK7_STATUS $ "0/1/4")
	aAdd(aButtons,	{"S4WB001N", {|| Hs_M12Conf()}, "Confirmar"})
EndIf

If Alltrim(Str(nOpcE)) $ "234"
	aAdd(aButtons,	{'PEDIDO', {|| FS_A120PED(nOpcE)}, STR0054,"Ped.Compr"})  //"Pedido de Compra"
EndIf

HS_BDados("GKA", @aHGKA, @aCGKA, @nUGKA, 1,, " GKA->GKA_SOLICI = '"+M->GK7_SOLICI+"'")//, .T.)

nGKACODITE := aScan(aHGKA, {| aVet | aVet[2] == "GKA_CODITE"})
nGKACODPRO := aScan(aHGKA, {| aVet | aVet[2] == "GKA_CODPRO"})
nGKADESPRO := aScan(aHGKA, {| aVet | aVet[2] == "GKA_DESPRO"})
If Empty(aCGKA[1, nGKACODITE])
	aCGKA[1, nGKACODITE]	:= StrZero(1, Len(aCGKA[1, nGKACODITE]))
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel

oEnGK7 := MsMGet():New("GK7" ,nReg ,nOpc,,,, aCpos  , {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,,oDlg,,.F.)
oEnGK7:oBox:align := CONTROL_ALIGN_TOP

oEnGK7:AENTRYCTRLS[aScan(oEnGK7:aGets, {| aVet | "GK7_CRMAUT" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := "8"}

oEnGK7:AENTRYCTRLS[aScan(oEnGK7:aGets, {| aVet | "GK7_CRMSOL" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := ""}
oEnGK7:AENTRYCTRLS[aScan(oEnGK7:aGets, {| aVet | "GK7_CRMRES" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := ""}
oEnGK7:AENTRYCTRLS[aScan(oEnGK7:aGets, {| aVet | "GK7_CRMEXC" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := ""}

oEnGK7:AENTRYCTRLS[aScan(oEnGK7:aGets, {| aVet | "GK7_CODPRO" $ aVet})]:BGOTFOCUS := {|| cSusProIns := "06"}

//aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4]
oFolder := TFolder():New(aPObjs[2, 1], aPObjs[2, 2],{"Laudo","Procedimentos"},{"Laudo","Procedimentos"},oDlg,,,,.T.,.F.,aPObjs[2, 3], aPObjs[2, 4])
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

If(nOpcE # 3)
	HS_BusResp("GK8", {{"GK8->GK8_SOLICI", GK7->GK7_SOLICI},{"GK8->GK8_CDQUES", GK7->GK7_CDQUES}}, "PER")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para indicar o Questionario/Status que permite alteracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If ExistBlock("HSPSTAAPAC")
    aStaQuest := ExecBlock( "HSPSTAAPAC",.F.,.F., {cCdQues} )   
    If aStaQuest[1]
        aMntperg := HS_MntPerg(cCdQues, oFolder:aDialogs[1]/*oDLg*/,, aPGets[1], nOpcE == 2 .Or. !(M->GK7_STATUS $ aStaQuest[2]), "PER" , "oEncQues",, "aTelaQues", CONTROL_ALIGN_ALLCLIENT,, "G", .T.)
    Else
        aMntperg := HS_MntPerg(cCdQues, oFolder:aDialogs[1]/*oDLg*/,, aPGets[1], nOpcE == 2 .Or. !(M->GK7_STATUS $ '0/4'), "PER" , "oEncQues",, "aTelaQues", CONTROL_ALIGN_ALLCLIENT,, "G", .T.)
    EndIf    
Else
    aMntperg := HS_MntPerg(cCdQues, oFolder:aDialogs[1]/*oDLg*/,, aPGets[1], nOpcE == 2 .Or. !(M->GK7_STATUS $ '0/4'), "PER" , "oEncQues",, "aTelaQues", CONTROL_ALIGN_ALLCLIENT,, "G", .T.)
EndIf

oGKA := MsNewGetDados():New(aPGets[1, 1],aPGets[1, 2], aPGets[1, 3],aPGets[1, 4], nOpcGd,,,"+GKA_CODITE",,,99999,,,, oFolder:aDialogs[2], aHGKA, aCGKA)
oGKA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGKA:oBrowse:bGotFocus :=  {|| cSusProIns := "06/07"}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets,aTela) .And. HS_ObrgPer(aMntPerg[3], aMntPerg[2]), oDlg:End(), nOpcDlg := 0)}, ;
{|| nOpcDlg := 0, oDlg:End()},,aButtons)

If nOpcDlg == 1 .And. nOpcE # 2
	Begin Transaction
	Fs_M12Grv("GK7", M->GK7_SOLICI,aRotina[nOpc, 4] == 5, lDevApac)
	HS_GrvResp("GK8", {{"GK8->GK8_SOLICI", M->GK7_SOLICI}, {"GK8->GK8_CDQUES", cCdQues}} , aMntperg[2])
	End Transaction
Else
	While __lSx8
		RollBackSxe()
	End
EndIF

MBrChgLoop(.F.)
RestKeys( aSvKeys , .T. )
Return(nil)

Function HS_M12DEV(cAlias, nReg, nOpc)

private lDevolve := .T.

If GK7->GK7_STATUS == '1'
	Hs_M12Rot(cAlias, nReg, nOpc)
Else
	Hs_MsgInf("Opção inválida para solicitação ["+GK7->GK7_SOLICI+"]","Atenção","Validação Devolução")
EndIf
Return(nil)

Function Hs_M12Conf()

Local lAutSApac := getMv("MV_LAPACSN",,.F.)

nOpcDlg := 0

If !(Obrigatorio(aGets,aTela) .And. HS_ObrgPer(aMntPerg[3], aMntPerg[2]))
	Return(nil)
EndIF

If M->GK7_STATUS == "0" .And. !Empty(M->GK7_NRAPAC)
	M->GK7_STATUS := Soma1(M->GK7_STATUS)
ElseIf M->GK7_STATUS == "1" .And. Empty(M->GK7_NRAPAC) .And. lAutSApac .And. !MsgYesNo("Não informado número do Apac."+chr(13)+"Deseja prosseguir?")
	Return(nil)
ElseIf M->GK7_STATUS == "4"
	M->GK7_STATUS := "0"
EndIf

M->GK7_STATUS := Soma1(M->GK7_STATUS)
nOpcDlg := 1
oDlg:End()

Return(nil)

Static Function Fs_M12Grv(cAliasGrv, cSolici, lExclui, lDevApac)
Local lAchou := .F.
Local nI := 0

Default lExclui := .F.

DbSelectArea(cAliasGrv)
DbSetOrder(1)
lAchou := DbSeek(xFilial(cAliasGrv)+cSolici)

If lExclui .And. !lAchou
	return(nil)
EndIf

RecLock(cAliasGrv, !lAchou)
If !lExclui
	HS_GRVCPO(cAliasGrv)
	&(cAliasGrv+"->"+cAliasGrv+"_FILIAL") := xFilial(cAliasGrv)
	&(cAliasGrv+"->"+cAliasGrv+"_SOLICI") := cSolici
	
	If lDevApac .And. cAliasGrv == "GK7"
		GK7->GK7_STATUS := IIF(Hs_IniPadr("GK9", 1, M->GK7_CODMOT, "GK9_RETMOT") == "1","4","5")
	EndIf
Else
	DbDelete()
EndIf
MsUnLock()

for nI := 1 to len(oGKA:aCols)
	
	If Empty(oGKA:aCols[nI, nGkaCodPro])
		Loop
	EndIF
	
	DbSelectArea("GKA")
	DbSetOrder(1)
	lAchou := DbSeek(xFilial("GKA")+M->GK7_SOLICI+oGKA:aCols[nI, nGkaCodIte])
	
	If lExclui .And. !lAchou
		Loop
	EndIf
	
	RecLock("GKA",!lAchou)
	
	If !lExclui
		GKA_FILIAL := xFilial("GKA")
		GKA_SOLICI := M->GK7_SOLICI
		GKA_CODITE := oGKA:aCols[nI, nGkaCodIte]
		GKA_CODPRO := oGKA:aCols[nI, nGkaCodPro]
	Else
		DbDelete()
	EndIf
	
	MsUnLock()
	
Next

ConfirmSx8()

Return(nil)

Function HS_M12AGD()
Local cSeqAge := ""
Local lOldInc := Inclui
Local lOldAlt := Altera
Local lAtuAgd := getMv("MV_LAPACSN",,.F.)

Private lCopiar := .T.
Private bCopia     := {|| Hs_M12CAgd() }
Private cGcsCodLoc := "" //Setor selecionado
Private aRotina    := {{"" ,"" , 0, 3, 0, nil},;
{"" ,"" , 0, 3, 0, nil},;
{"" ,"" , 0, 3, 0, nil}}

If !Hs_ExisDic({{"C","GK7_SEQAGE"}},.F.) .Or. GK7->GK7_STATUS > '3'
	MsgAlert("Opção não disponível")
ElseIf GK7->GK7_STATUS < '2' .And. !lAtuAgd
	MsgAlert("Opção inválida para solicitação ["+GK7->GK7_SOLICI+"]")
Else
	If Empty(GK7->GK7_SEQAGE)
		If HSPM29Perg()
			Inclui  := .T.
			lAltera := .F.
			DbSelectArea("GM8")
			cSeqAge := HSPM29Atu('GM8', GM8->(RecNo()), 2)
			
			If !Empty(cSeqAge)
				RecLock("GK7", .F.)
				GK7->GK7_SEQAGE := cSeqAge
				GK7->GK7_STATUS := '3'
				MsUnLock()
			EndiF
			Inclui := lOldInc
			Altera := lOldAlt
		EndIf
	Else
		Fs_ExbAgd(GK7->GK7_SOLICI)
	EndIf
EndIf

Return(nil)

//Função utilizada para carregar variaveis de memoria da agenda
Function Hs_M12CAgd()
Local aVar := {{"GM8_REGGER","GM8REGGER"},{"GM8_NOMPAC","GM8NOMPAC"},{"GM8_MATRIC","GM8MATRIC"},{"GM8_TELPAC","GM8TELPAC"},;
{"GM8_CODPLA","GM8CODPLA"},{"GM8_SQCATP","GM8SQCATP"},{"GM8_CODPRO", "GM8CODPRO"},{"GM8_CODCRM","GM8CODCRM"}}
Local nCont := 0
Local cValid := ""


Private GM8REGGER := GK7->GK7_REGGER
Private GM8NOMPAC := Space(TamSx3("GBH_NOME")[1])
Private GM8MATRIC := Space(TamSx3("GM8_MATRIC")[1])
Private GM8TELPAC := Space(TamSx3("GM8_TELPAC")[1])
Private GM8CODPLA := Space(TamSx3("GM8_CODPLA")[1])
Private GM8SQCATP := Space(TamSx3("GM8_SQCATP")[1])
Private GM8CODPRO := GK7->GK7_CODPRO
Private GM8CODCRM := GK7->GK7_CRMEXC

HS_SeekRet("GBH", "GK7->GK7_REGGER"  ,1,.F.,{"GM8NOMPAC","GM8TELPAC"},{"GBH_NOME","GBH_TEL"})
HS_SeekRet("GD4", "GK7->GK7_REGGER+'1'",2,.F.,{"GM8MATRIC","GM8CODPLA","GM8SQCATP"},{"GD4_MATRIC","GD4_CODPLA","GD4_SQCATP"})

For nCont := 1 to Len(aVar)
	__ReadVar := "M->"+aVar[nCont, 1]
	&("M->"+aVar[nCont, 1]) := &(aVar[nCont, 2])
	cValid := HS_CfgSx3(aVar[nCont, 1])[SX3->(FieldPos("X3_VALID"))]
	IF !Empty(&("M->"+aVar[nCont, 1])) .And. !Empty(cValid) .And. !&(cValid)
		Exit
	EndIf
	
Next

If Type("oGO4") <> 'U'
	DbSelectArea("GKA")
	DbSetOrder(1)
	If DbSeek(xFilial("GKA")+GK7->GK7_SOLICI)//GKA_FILIAL+GKA_SOLICI+GKA_CODITE
		
		While GKA->(!Eof()) .And. GKA->GKA_SOLICI == GK7->GK7_SOLICI
			//oGO4:aHeader
			If !Empty(oGO4:aCols[oGO4:nAt, nGO4_CODPRO])
				oGO4:AddLine(.T., .F.)
				oGO4:lNewLine := .F.
			EndIf
			
			__ReadVar := "M->GO4_CODPRO"
			&("M->GO4_CODPRO") := GKA->GKA_CODPRO
			
			oGO4:aCols[oGO4:nAt, nGO4_CODPRO] := GKA->GKA_CODPRO
			
			If(!&(oGO4:aHeader[nGO4_CODPRO, 6]))
				oGO4:aCols[oGO4:nAt, nGO4_CODPRO] := Space(TamSx3("GKA_CODPRO")[1])
			EndIf
			
			GKA->(DbSkip())
		EndDo
	EndIf
EndIf

Return(nil)

Static Function Fs_ExbAgd(cSolici)
Local cSql    := ""
Local aCDados := {}
Local aHDados := {}
Local aArea   := getArea()
Local aButtons := {}

Private cAliasGm8 := "TMPGK7"

Aadd(aButtons, {"BR_VERDE_OCEAN", {|| HSPAHM29LEG()}, "Legenda", "Legenda"})

aSize := MsAdvSize(.T.)

cSql := " SELECT GM8_STATUS, GM8_DATAGE, GM8_HORAGE, GM8_CODSAL, GF3.GF3_DESCRI, "
cSql += "        GM8_CODREC, GNZ_DESREC, GM8_CODCRM, RA_NOME "
cSql += "  FROM "+RetSqlName("GK7")+" GK7 "
cSql += "  JOIN "+RetSqlName("GM8")+" GM8 "
cSql += "    ON GM8.GM8_SEQAGE = GK7.GK7_SEQAGE AND GM8.GM8_CODAGE = GM8.GM8_AGDPRC "
cSql += "   AND GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*'  "
cSql += "  JOIN "+RetSqlName("SRA")+" SRA "
cSql += "    ON SRA.RA_FILIAL = '"+xFilial("SRA")+"' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GM8.GM8_CODCRM "
cSql += "  JOIN "+RetSqlName("GF3")+" GF3 "
cSql += "    ON GF3.GF3_FILIAL = '"+xFilial("GF3")+"' AND GF3.D_E_L_E_T_ <> '*' AND GF3.GF3_CODIGO = GM8.GM8_CODSAL "
cSql += "  JOIN "+RetSqlName("GNZ")+" GNZ "
cSql += "    ON GNZ.GNZ_FILIAL = '"+xFilial("GNZ")+"' AND GNZ.D_E_L_E_T_ <> '*' AND GNZ.GNZ_CODREC = GM8.GM8_CODREC "
cSql += " WHERE GK7.GK7_FILIAL = '"+xFilial("GK7")+"' AND GK7.D_E_L_E_T_ <> '*' "
cSql += "   AND GK7_SOLICI = '"+cSolici+"' "
cSql += " ORDER BY GM8_DATAGE ASC "

TCQuery cSql New Alias "TMPGK7"

While TMPGK7->(!Eof())
	aAdd(aCDados,{HSPM29SitAge()    , StoD(TMPGK7->GM8_DATAGE),TMPGK7->GM8_HORAGE, TMPGK7->GM8_CODCRM, TMPGK7->RA_NOME,;
	TMPGK7->GM8_CODSAL, TMPGK7->GF3_DESCRI      , TMPGK7->GM8_CODREC, TMPGK7->GNZ_DESREC, .F.})
	TMPGK7->(DbSkip())
EndDo

Aadd(aHDados, {" "          , "cStatus" , "@BMP"  , 2                      , 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Data Agenda", "dDatAge" , "@D"    , Len(TMPGK7->GM8_DATAGE), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Hora Agenda", "cHorAge" , "@99:99", Len(TMPGK7->GM8_HORAGE), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

Aadd(aHDados, {"Profissional", "cMedico", "@!"    , Len(TMPGK7->GM8_CODCRM), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Nome"        , "cNome"  , "@!"    , Len(TMPGK7->RA_NOME)   , 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

Aadd(aHDados, {"Sala"       , "cSala"   , "@!"    , Len(TMPGK7->GM8_CODSAL), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Descrição"  , "cDesSal" , "@!"    , Len(TMPGK7->GF3_DESCRI), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Recurso"    , "cRecurso", "@!"    , Len(TMPGK7->GM8_CODREC), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Descrição"  , "cDesRec" , "@!"    , Len(TMPGK7->GNZ_DESREC), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Agendamentos") From aSize[5]/5, aSize[6]/100 To aSize[6], aSize[5]*0.65	PIXEL Of oMainWnd

oGDDados := MsNewGetDados():New(0, 0, 200, 200, 0,,,,,,,,,, oDlg, aHDados, aCDados)
oGDDados:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {|| oDlg:End()},, aButtons)

DbSelectArea("TMPGK7")
DbCloseArea()

RestArea(aArea)
return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M12VLD ºAutor  ³Microsiga           º Data ³  05/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Funcao de validacao dos dados da solicitacao APAC         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HSPAHM12                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_M12VLD()

Local aNomMed 		:= {{"GK7_CRMSOL","GK7_NOMMED"},{"GK7_CRMEXC", "GK7_MEDEXC"},{"GK7_CRMRES", "GK7_MEDRES"},{"GK7_CRMAUT", "GK7_MEDRES"}}
Local aVldApac  	:= {}
Local aContBpa		:= {}
Local aContApac 	:= {}
Local cMsgErro  	:= ""
Local cDtIni    	:= ""
Local cDtFim    	:= ""
Local cStApac   	:= ""
Local cCodApac  	:= ""
Local cCodBpa		:= ""
Local nCount 		:= 0
Local nI			:= 0
Local lRet 			:= .T.
Local lBloq			:= .F. // .T. se o cod. Convenio do paciente esta informado no MV_APAC 
Local lExBlqApac	:= .F. // .T. se o paciente já possui uma APAC vigente para o período


GK7->(dbSetOrder(2)) //GK7_FILIAL+GK7_REGGER

GD4->(dbSelectArea("GD4"))// Tabela de PACIENTE x PLANO
GD4->(dbSetOrder(2)) //GD4_FILIAL+GD4_REGGER+GD4_IDPADR

If ReadVar() == "M->GK7_TPLAUD"
	cTab := &(ReadVar())
	If(!Empty(cTab) .And. cTab <> "0" .And. Len(oEnGK8:oBox:aDialogs) >= val(cTab))
		//Fs_SetFold(cTab)
		oEnGK8:SetFocus(val(cTab))//:oBox:aDialogs[val(cTab)]:SetFocus()
		oEnGK8:OBOX:NOPTION := val(cTab)
		oEnGK8:Refresh()//:oBox:aDialogs[val(cTab)]:Refresh()
	EndIf
ElseIf ReadVar() == "M->GK7_REGGER"
	If !(lRet := HS_SeekRet("GBH", ReadVar(), 1, .F., "GK7_NOMPAC", "GBH_NOME",,, .T.) )
		Hs_MsgInf("Prontuário não encontrado","Atenção", "Validação Solicitação de APAC")
	Else
		__cProntu := &(ReadVar())
	EndIf
ElseIf ReadVar() == "M->GK7_CODPRO"
	If !(lRet := HS_SeekRet("GA7", ReadVar(), 1, .F., "GK7_DESPRO", "GA7_DESC",,, .T.) )
		Hs_MsgInf("Procedimento não encontrado","Atenção", "Validação Solicitação de APAC")
	Else
		cCodProSus := &(ReadVar())
	EndIf
	
ElseIf ReadVar() == "M->GK7_REGATE"
	If !(lRet := HS_SeekRet("GCY", ReadVar(), 1, .F., "GK7_CRMSOL", "GCY_CODCRM",,, .T.) .And. HS_SeekRet("SRA", "M->GK7_CRMSOL", 11, .F., "GK7_NOMMED", "RA_NOME",,, .T.) )
		Hs_MsgInf("Atendimento não encontrado","Atenção", "Validação Solicitação de APAC")
	EndIf
	
ElseIf ReadVar() == "M->GK7_CODMOT"
	If !(lRet := HS_SeekRet("GK9", ReadVar(), 1, .F., "GK7_DESMOT", "GK9_DESMOT",,, .T.) )
		Hs_MsgInf("Motivo não encontrado","Atenção", "Validação Solicitação de APAC")
	EndIf
ElseIf ReadVar() $ "M->GK7_NRAPAC/M->GK7_NAPACN"
	If !(lRet := (aVldApac := Hs_VldM11(&(ReadVar()), 13,1,,.T.))[1])
		Hs_MsgInf(aVldApac[2],"Atenção", "Validação Solicitação de APAC")
	EndIf
ElseIf ReadVar() == "M->GK7_DTINVL"
	If GetMv("MV_VLDGUIA",,0) > 0
		M->GK7_DTFIVL := &(ReadVar())+GetMv("MV_VLDGUIA",,0)
	EndIf
	If GK7->(dbSeek(xFilial("GK7")+M->GK7_REGGER)) 
		If GD4->(dbSeek(xFilial("GD4")+M->GK7_REGGER+"1"))// FILIAL + PRONTUARIO + COD. PLANO SELECIONADO
 	     	If AllTrim(GD4->GD4_CODPLA) $ GetNewPar("MV_HSPAPAC"," ")  // MV_APAC vs Cod Plano Paciente
				lBloq := .T. // Bloqueio APAC
			EndIf                                                                 
		   If lBloq // Cod. Plano do Pacinte esta informado no MV_HSPAAPAC			
				While GK7->(!Eof()) .And. GK7->GK7_REGGER == M->GK7_REGGER 
					cDtIni  := GK7->GK7_DTINVL
					cDtFim  := GK7->GK7_DTFIVL
					cStApac := GK7->GK7_STATUS                                                                                                            // 4 = Devolvidas // 5 = Canceladas
					If (( M->GK7_DTINVL <= cDtIni .And. M->GK7_DTFIVL >= cDtIni) .Or. (M->GK7_DTINVL <= cDtFim .And. M->GK7_DTFIVL >= cDtFim)) .And. !(cStApac == "4" .Or. cStApac == "5")
						lExBlqApac:= .T.  //Paciente já possui uma APAC vigente para o período.
						Exit
					EndIf 
					GK7->(dbSkip()) 
				End
			EndIf
		EndIf
		If lExBlqApac 
			Hs_MsgInf("Já existe uma APAC vigente,  no período de " +DtoC(cDtIni)+ " a " +DtoC(cDtFim)+", para este paciente.","Atenção", "Validação Solicitação de APAC")
			lRet:= .F.
		EndIf
	EndIf
ElseIf ReadVar() == "M->GK7_DTFIVL"
	If !(lRet := M->GK7_DTFIVL > M->GK7_DTINVL)
		Hs_MsgInf("Data final da validade não pode ser superior à Inicial","Atenção", "Validação Solicitação de APAC")
	EndIf
ElseIf ReadVar() $ "M->GK7_CRMSOL/M->GK7_CRMEXC/M->GK7_CRMRES/M->GK7_CRMAUT"
	If !(lRet := HS_SeekRet("SRA", ReadVar(), 11, .F., aNomMed[ aScan(aNomMed,{|aVet|  "M->"+aVet[1] == ReadVar() }), 2], "RA_NOME",,, .T.) )
		Hs_MsgInf("Profissional não encontrado","Atenção", "Validação Solicitação de APAC")
	EndIf
ElseIf ReadVar() == "M->GKA_CODPRO"
	If !Empty( Select( "GK7" ) )
		If !(lRet := HS_SeekRet("GA7", ReadVar(), 1, .F., "oGka:aCols[oGka:nAt, nGkaDesPro]", "GA7_DESC",,, .T.) )
			Hs_MsgInf("Procedimento não encontrado","Atenção", "Validação Solicitação de APAC")
		ElseIf !(lRet := Hs_VlComp(M->GK7_CODPRO, "06", &(ReadVar()), "06/07", , @cMsgErro))
			Hs_MsgInf(cMsgErro,"Atenção", "Validação Solicitação de APAC")
			oGka:aCols[oGka:nAt, nGkaDesPro] := Space(TamSx3("GKA_DESPRO")[1])
		EndIf
	Else
		HS_M13VLD()
	EndIf
EndIf

Return(lRet)

Function Hs_VlComp(cCodProPr, cInsRegPr, cCodProSeg, cInsRegSeg, nQtd, cMsgErro)
Local aArea      := getArea()
Local lRet       := .T.
//Local cInsReg    := "%"+HS_InSql(cInsRegSeg)+"%"
Local cInsReg    := HS_InSql(cInsRegSeg)
Local cSql       := ""

Default nQtd     := 0
Default cMsgErro := ""


cSql += "  SELECT GLF_TPCOMP, GLF_QTPERM "
cSql += "		  FROM "+RetSqlName("GLF")+" GLF "
cSql += "   WHERE GLF.GLF_CDPROP = '" + cCodProPr + "'  AND GLF.GLF_CDREGP = '"+cInsRegPr+"' "
cSql += "     AND GLF.GLF_CDPROC = '" + cCodProSeg + "' AND GLF.GLF_CDREGC In ("+cInsReg+") "
cSql += "     AND GLF.GLF_FILIAL = '" + xFilial("GLF")+ "' AND GLF.D_E_L_E_T_ <> '*' "

TCQuery cSql New Alias "QRYM12VLD"
/* Embebed SQL
BeginSql alias "QRYM12VLD"
SELECT GLF_TPCOMP, GLF_QTPERM
FROM %table:GLF% GLF
WHERE GLF.GLF_CDPROP = %exp:cCodProPr%  AND GLF.GLF_CDREGP = %exp:cInsRegPr%
AND GLF.GLF_CDPROC = %exp:cCodProSeg% AND GLF.GLF_CDREGC In (%exp:cInsReg%)
AND GLF.GLF_FILIAL = %xFilial:GLF%    AND GLF.%NotDel%
EndSql
*/

If(QRYM12VLD->(Eof()))
  cMsgErro := STR0064 //"Procedimento informado não pode ser secundário em APAC"
	lRet     := .F.
EndIf

While QRYM12VLD->(!Eof())
	If(QRYM12VLD->GLF_TPCOMP $ "1/3")
		If(QRYM12VLD->GLF_QTPERM <> 0 .And. nQtd <> 0 .And. QRYM12VLD->GLF_QTPERM < nQtd)
			cMsgErro := "Número máximo de procedimentos permitidos excedido"
			lRet     := .F.
		EndIf
	Else
   cMsgErro := STR0064 //"Procedimento informado não pode ser secundário em APAC"
		lRet     := .F.
	EndIf
	QRYM12VLD->(DbSkip())
EndDo
QRYM12VLD->(DbCloseArea())
RestArea(aArea)
Return(lRet)

Function HS_M12TPL()
Local aArea := getArea()
Local cRet  := ""

DbSelectArea("SXA")
DbSetOrder(1)
DbSeek("GK8")

While SXA->(!Eof()) .And. SXA->XA_ALIAS == "GK8"
	cRet += IIf(!Empty(cRet),";","")+AllTrim(XA_ORDEM)+"="+AllTrim(XA_DESCRIC)
	SXA->(DbSkip())
EndDo

RestArea(aARea)
Return(cRet)

Static Function Fs_RetQues()
Local aArea := getArea()
Local cRet := ""
Local nOpca := 0
Private aHGFS := {}, aCGFS := {}, nUGFS := 0

HS_BDados("GFS" , @aHGFS , @aCGFS , @nUGFS , 1   ,        , " GFS.GFS_TPQUES = '2' AND GFS.GFS_IDATIV = '1' ",        ,        ,"/"      ,         ,        ,        ,        ,        ,.T.     ,     ,        ,         ,           ,         ,{"GFS_CDQUES","GFS_DSQUES"},      ,          ,         ,         ,         ,           )
nGFSCDQUES := aScan(aHGFS, {|aVet| aVet[2] == "GFS_CDQUES"})

DEFINE MSDIALOG oDlgQues TITLE "Selecione questionário para digitação do Laudo" From 000, 000 To 300, 500 Of oMainWnd Pixel

oGFS := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlgQues, aHGFS, aCGFS)
oGFS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgQues CENTERED ON INIT EnchoiceBar(oDlgQues, {||nOpca := 1, oDlgQues:End()}, {|| nOpca := 0, oDlgQues:End()})

If nOpca == 1
	cRet := oGFS:aCols[oGFS:nAt, nGFSCDQUES]
EndIf

RestArea(aArea)
return(cRet)

Function HS_M12LEG()
Local aLegenda := {{"BR_VERDE"   , OemToAnsi("Solicitada")}, ;
{"BR_AMARELO" , OemToAnsi("Aguardando Autorização")}, ;
{"BR_AZUL"    , OemToAnsi("Autorizada")}, ;
{"BR_LARANJA" , OemToAnsi("Agendada")}, ;
{"BR_VERMELHO", OemToAnsi("Devolvida")}, ;
{"BR_CINZA"   , OemToAnsi("Cancelada")}}

BrwLegenda("Solicitação APAC","Legenda", aLegenda)
Return(nil)

Static Function FS_FilM12(lSetFilter)

Local lRet     := .F.
Local oObjMBrw := GetObjBrow()
Local dDatIni := CtoD(""), dDatFim := CtoD(""), cStatus := ""

If (lRet := Pergunte("HSPM12"))
	dDatIni := MV_PAR01
	dDatFim := MV_PAR02
	cStatus := AllTrim(MV_PAR03)
	
	cFilM12 := "     GK7_FILIAL = '" + xFilial("GK7") + "' AND GK7_DATSOC BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "'"
	cFilM12 += " AND GK7_STATUS IN (" + HS_InSql(cStatus) + ") "
	If lSetFilter
		MsgRun("Selecionando as Solicitações ...", "Aguarde ...", {|| SetMBTopFilter("GK7", cFilM12), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando os Agendamentos..."###"Aguarde..."
	EndIf
EndIf

DbSelectArea("GK7")

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Bruno Santos          ³ Data ³ 20/08/07 ³±±
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
Local aRotina :=	{}
Local cUsaSUS := GetMv("MV_ATESUS")

aAdd(aRotina, {"Pesquisar" ,"AxPesqui" , 0, 1, 0, nil})
aAdd(aRotina, {"Visualizar","HS_M12ROT", 0, 2, 0, nil})
aAdd(aRotina, {"Solicitar","HS_M12ROT", 0, 3, 0, nil})
aAdd(aRotina, {"Alterar"  ,"HS_M12ROT", 0, 4, 0, nil})
aAdd(aRotina, {"Devolver" ,"HS_M12DEV", 0, 4, 0, nil})
aAdd(aRotina, {"Legenda"  ,"HS_M12LEG", 0, 4, 0, nil})
aAdd(aRotina, {"Envia Cd Bar"  ,"HS_M12EACB('E')", 0, 4, 0, nil})
aAdd(aRotina, {"Autor Cd Bar"  ,"HS_M12EACB('A')", 0, 4, 0, nil})

If cUsaSUS == "S"
	aADD(aRotina,{STR0045, "hs_relatSu()", 0, 2, 0, nil})//"Relat. SUS"
EndIf

Return(aRotina)

Function Hs_FilCBox(cCampo, cTitulo)

Local aArea   := getArea()

Local aHDados := {}
Local aCDados := {}
Local nCont   := 0
Local nOpca   := 0
Local nPos    := 0
Local cRet    := ""

Default cTitulo := "Selecione os Status para o filtro"

Aadd(aHDados, {"", "cMark", "@BMP" , 5, 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Status", "cStatus", "@!" , 1, 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Descrição", "cDesc", "@!" , 30, 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

//aAdd(aCDados,{"LBNO","","Todos",.F.})

cX3BOX := HS_CfgSx3(cCampo)[SX3->(FieldPos("X3_CBOX"))]+";"

While (nPos := at(";",cX3BOX)) > 0
	cAux   := SubStr(cX3Box, 1, nPos-1)
	cX3Box := SubStr(cX3Box, nPos+1)
	
	aAdd(aCDados,{"LBTIK",SubStr(cAux, 1,aT("=",cAux)-1),SubStr(cAux, aT("=",cAux)+1),.F.})
Enddo

DEFINE MSDIALOG oDlgStatus TITLE cTitulo From 000, 000 To 180, 350 Of oMainWnd Pixel

oGdStatus := MsNewGetDados():New(000, 000, 200, 200,0,,,,,,,,,, oDlgStatus, aHDados, aCDados)
oGdStatus:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdStatus:oBrowse:blDblClick:= {|| Fs_DbCStat(oGdStatus) } //Marca o Agendamento pela Ocupacao

ACTIVATE MSDIALOG oDlgStatus CENTERED ON INIT EnchoiceBar(oDlgStatus, {||nOpca := 1, oDlgStatus:End()}, {|| nOpca := 0, oDlgStatus:End()})


If nOpca == 1
	cRet := ""
	For nCont := 1 to Len(oGdStatus:aCols)
		If oGdStatus:aCols[nCont, 1] == "LBTIK"
			cRet += IIF(Empty(cRet),"","/")+AllTrim(oGdStatus:aCols[nCont, 2])
		EndIf
	Next
EndIf

__RetStatus := cRet
RestArea(aArea)
Return(.T.)

Function HS_RetCBox()
&(Readvar()) := __RetStatus
Return(.T.)

Static Function Fs_DbCStat(oObj, nPos)

Default nPos := 1

If oObj:aCols[oObj:nAt, nPos] == "LBTIK"
	oObj:aCols[oObj:nAt, nPos] := "LBNO"
Else
	oObj:aCols[oObj:nAt, nPos] := "LBTIK"
EndIf
Return(nil)


//Controle de Sessões
Function Hs_CtrSes(cAlias, nReg, nOpc)

Local cSql := ""
Local cGk7Solici := ""
Local aHGm8 := {}, aCGm8 := {}, nUGm8 := 0
Local cCadastro := "Controle Sessões"
Local aCpos     := {}
Local nHd		:= 0
Local aArea     := getArea()
Local aCpoGM8   := {"GM8_DATAGE","GM8_HORAGE","GM8_CODPRO","GM8_DESPRO","GM8_CODCRM",;
"GM8_NOMCRM","GM8_CODAGE","GM8_CODPLA","GM8_DESPLA","GM8_CODLOC", "GM8_ORICAN","GM8_MOTIVO"}
Local aButtons  := {}
Local cLocReab := GetMv("MV_LOCREAB",,"")

Private aLeg := {{"GM8_STATUS == '0' ","BR_CINZA"},;
{"GM8_STATUS == '1' ","BR_VERMELHO"},;
{"GM8_STATUS == '2' ","BR_AMARELO" },;
{"GM8_STATUS == '3' ","BR_PINK" },;
{"GM8_STATUS == '4' ","BR_AZUL" },;
{"GM8_STATUS == '5' ","BR_LARANJA" }}

Private oEnGK7, oGDGm8
Private aTela   := {}, aGets := {}
Private aPGets := {}
Private nOpcDlg := 0
Private aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Private nOpcE   := GD_UPDATE //aRotina[nOpc, 4]

Private cGm8CodAge := ""
Private cGm8CodPla := ""
Private nGm8Status := 0
Private nGm8IdMarc := 0
Private nGm8CodPro := 0
Private nGm8CodAge := 0
Private nGm8CodPla := 0
Private nGm8CodLoc := 0
Private nGm8CodCrm := 0
Private nGm8DatAge := 0
Private nGm8OriCan := 0
Private nGm8Motivo := 0

If !Hs_ExisDic({{"C","GK7_SEQAGE","FNC 148152"}})
	Return(Nil)
ElseIf !(GCY->GCY_CODLOC $ cLocReab)
	Hs_MsgInf("Setor selecionado não é de 'Reabilitação'.","Atenção","Controle Sessões")
	Return(Nil)
EndIf

Aadd(aButtons, {"BR_VERDE_OCEAN", {|| HSPAHM29LEG()}, "Legenda", "Legenda"})

aSize 			:= MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
aAdd( aObjects, { 100, 100, .T., .T.} )

aInfo  := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGets := MsObjSize( aInfo, aObjects, .T., .T., .T.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GK7")
While SX3->(!Eof()) .And. X3_ARQUIVO == "GK7"
	If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. (!SX3->X3_CAMPO $ "GK7_CODMOT/GK7_DESMOT")
		Aadd(aCpos, SX3->X3_CAMPO)
	EndIf
	DbSkip()
EndDo

cSql := " SELECT GK7.R_E_C_N_O_ GK7_RECNO, GM8.R_E_C_N_O_ GM8_RECNO"
cSql += "   FROM "+RetSqlName("GK7")+" GK7  "
cSql += "			JOIN "+RetSqlName("GM8")+" GM8 ON GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' AND GM8_CODAGE = GM8_AGDPRC "
cSql += "			 AND GK7_SEQAGE = GM8_CODAGE  AND GM8_REGATE = '"+GCY->GCY_REGATE+"' "
cSql += "  WHERE GK7.GK7_FILIAL = '"+xFilial("GK7")+"' AND GK7.D_E_L_E_T_ <> '*' "

TCQUERY cSQL NEW ALIAS "QRYM12"

If QRYM12->(EoF())
	Hs_MsgInf("Não há sessões pendentes para esse atendimento.","Atenção","Controle Sessões")
	DbSelectArea("QRYM12")
	DbCloseArea()
	Return(Nil)
EndIf

DbSelectArea("GK7")
DbSetOrder(1)
DbGoTo(QRYM12->GK7_RECNO)

RegToMemory("GK7", .F.)

cGk7Solici := GK7->GK7_SOLICI


DbSelectArea("GM8")
DbSetOrder(1)
DbGoTo(QRYM12->GM8_RECNO)

cGm8CodAge := GM8->GM8_CODAGE
cGm8CodPla := GM8->GM8_CODPLA

HS_BDados("GM8", @aHGm8, @aCGm8, @nUGm8, 1,," GM8_AGDPRC = GM8_CODAGE AND GM8_SEQAGE = '"+cGm8CodAge+"' ",,"GM8_STATUS","/",,,,{"GM8_IDMARC"}, {"Iif(GM8_STATUS == '3', 'LBTIK', 'LBNO')"},.T.,aLeg,,,,, aCpoGM8	)

For nHd := 1 To Len(aHGm8)
	If 	aHGm8[nHd,02] $ "GM8_MOTIVO/GM8_ORICAN"
		aHGm8[nHd,17] := .F.
	EndIf
Next nHd

nGm8Status := aScan(aHGm8, {|aVet| aVet[2] == "GM8_STATUS"})
nGm8IdMarc := aScan(aHGm8, {|aVet| aVet[2] == "GM8_IDMARC"})
nGm8CodPro := aScan(aHGm8, {|aVet| aVet[2] == "GM8_CODPRO"})
nGm8CodAge := aScan(aHGm8, {|aVet| aVet[2] == "GM8_CODAGE"})
nGm8CodPla := aScan(aHGm8, {|aVet| aVet[2] == "GM8_CODPLA"})
nGm8CodLoc := aScan(aHGm8, {|aVet| aVet[2] == "GM8_CODLOC"})
nGm8CodCrm := aScan(aHGm8, {|aVet| aVet[2] == "GM8_CODCRM"})
nGm8DatAge := aScan(aHGm8, {|aVet| aVet[2] == "GM8_DATAGE"})
nGm8OriCan := aScan(aHGm8, {|aVet| aVet[2] == "GM8_ORICAN"})
nGm8Motivo := aScan(aHGm8, {|aVet| aVet[2] == "GM8_MOTIVO"})

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel

oEnGK7 := MsMGet():New("GK7" ,QRYM12->GK7_RECNO ,nOpc,,,, aCpos  , {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,,oDlg,,.F.)
oEnGK7:oBox:align := CONTROL_ALIGN_TOP

// MsNewGetDados(): New ( [ nTop], 			[ nLeft], 	  [ nBottom],   [ nRight ], [ nStyle], [ cLinhaOk], [ cTudoOk], [ cIniCpos], [ aAlter], [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela] ) --> Objeto                                                                                                                              //aAlter = Vetor com os campos que poderão ser alterados.
oGDGm8 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],nOpcE,"AllwaysTrue()","AllwaysTrue()","",{"GM8_ORICAN","GM8_MOTIVO"},,,,,,oDlg,aHGM8,aCGM8)
oGDGm8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
//oGDGm8:oBrowse:blDblClick:= {||  IIF( oGDGm8:aCols[oGDGm8:nAt, nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .AND. oGDGm8:oBrowse:ColPos <> nGm8OriCan .AND. oGDGm8:oBrowse:ColPos <> nGm8Motivo, Fs_DbCStat(oGDGm8, nGm8IdMarc), oGDGm8:EDITCELL( oGDGm8:OBROWSE, oGDGm8:oBrowse:nAt, oGDGm8:oBrowse:nColPos ))} //Marca o Agendamento pela Ocupacao
oGDGm8:oBrowse:blDblClick:= {||  IIF( oGDGm8:aCols[oGDGm8:nAt, nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .AND. oGDGm8:oBrowse:ColPos <> nGm8OriCan .AND. oGDGm8:oBrowse:ColPos <> nGm8Motivo, Fs_DbCStat(oGDGm8, nGm8IdMarc), IIF( oGDGm8:aCols[oGDGm8:nAt, nGm8Status] $ "BR_VERMELHO/BR_AZUL",oGDGm8:EDITCELL( oGDGm8:OBROWSE, oGDGm8:oBrowse:nAt, oGDGm8:oBrowse:nColPos ),NIL))} //Marca o Agendamento pela Ocupacao



ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIF(Fs_VldCtrl(),nOpcDlg := 1,nOpcDlg := 0), oDlg:End() }, ;
{|| nOpcDlg := 0, oDlg:End() },, aButtons)

If nOpcDlg == 1 .And. aScan(oGDGm8:aCols, {|aVet| aVet[nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. (aVet[nGm8IdMarc] == "LBTIK" .OR. !Empty(aVet[nGm8Motivo]))}) # 0
	Begin Transaction
	Fs_GrvCtrl()
	End Transaction
EndIF

DbSelectArea("QRYM12")
DbCloseArea()

RestArea(aArea)
MBrChgLoop(.F.)
Return(nil)


Static Function Fs_VldCtrl()
Local lRet := .F.


If aScan(oGDGm8:aCols, {|aVet| aVet[nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. aVet[nGm8IdMarc] == "LBTIK"}) == 0
	return(.T.)
EndIf

If !(lRet := dDataBase < GK7->GK7_DTFIVL)
	lRet := MsgYesNO("Validade da solicitação de APAC expirada."+Chr(13)+Chr(10)+"Deseja continuar?")
EndIf

Return(lret)

Static Function Fs_GrvCtrl()
Local aArea   := getArea()
Local aProced := {}
Local nCont, nContPro   := 0
Local lRet    := .T.
Local cNrSeqG := ""
Local cMsgGNova := "Deseja lançar nova guia no Atendimento?"
Local cMsgNGcz  := "Não foi encontrado guia(s) em aberto no Atendimento. Deseja lançar nova guia para a(s) despesa(s) ?"
Local bFnGerGui := {|| Fs_GerGuia(GCY->GCY_REGATE, GCY->GCY_REGGER, "0", GCY->GCY_ATENDI, GCY->GCY_DATATE, GCY->GCY_LOCATE, cGm8CodPla,, " ")} //HSPAHM17
Local aHMM := {}, aCMM := {}, nUMM := 0

// Cancelamento
For nCont := 1 To Len(oGDGm8:aCols)
	If !Empty(oGDGm8:aCols[nCont, nGm8OriCan]) .AND. !Empty(oGDGm8:aCols[nCont, nGm8Motivo]) .AND. HS_ExisDic({{"C", "GM7_AVISO"}}, .F.)
		Fs_BloqGM8(oGDGm8:aCols[nCont, nGm8CodAge], oGDGm8:aCols[nCont, nGm8Motivo], oGDGm8:aCols[nCont, nGm8OriCan])
	EndIf
Next nCont

If aScan(oGDGm8:aCols, {|aVet| aVet[nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. aVet[nGm8IdMarc] == "LBTIK"}) == 0
	Return(Nil)
EndIf

cNrSeqG := Hs_RetGuia(GCY->GCY_REGATE, GCY->GCY_REGGER, GCY->GCY_ATENDI, GCY->GCY_DATATE, GCY->GCY_LOCATE, ;
cGm8CodPla, , , cMsgGNova, cMsgNGcz, , bFnGerGui )
DbSelectArea("GCZ")
DbSetOrder(1)

If !Empty(cNrSeqG) .And. DbSeek(xFilial("GCZ")+cNrSeqG)
	
	If !Empty(GK7->GK7_NRAPAC)
		RecLock("GCZ",.F.)
		If HS_CountTB("GCZ", " GCZ_NRGUIA  = '" + GK7->GK7_NRAPAC + "' AND GCZ_NRSEQG <> '"+cNrSeqG+"' ") == 0
			GCZ->GCZ_TPAPAC := "1"
		Else
			GCZ->GCZ_TPAPAC := "2"
		EndIf
		
		GCZ->GCZ_NRGUIA := GK7->GK7_NRAPAC
		MsUnLock()
	EndIf
	
	For nCont := 1 To Len(oGDGm8:aCols)
		If oGDGm8:aCols[nCont, nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. oGDGm8:aCols[nCont, nGm8IdMarc] == "LBTIK";
			.AND. Empty(oGDGm8:aCols[nCont, nGm8OriCan]) .AND. Empty(oGDGm8:aCols[nCont, nGm8Motivo])
			
			aProced := Hs_RtPrAgd(oGDGm8:aCols[nCont, nGm8CodAge], oGDGm8:aCols[nCont, nGm8CodPro])
			
			For nContPro := 1 to len(aProced)
				cSeqDes := GetSxENum("GD7","GD7_SEQDES",,1)
				ConfirmSx8()
				
				aRValDes := HS_RValPr(aProced[nContPro], HS_INIPADR("GD4",1, GCY->GCY_REGGER, "GD4_CODPLA",,.T.), oGDGm8:aCols[nCont, nGm8CodLoc],;
				Time(), "2", oGDGm8:aCols[nCont, nGm8CodCrm], "", {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE},;
				.T., oGDGm8:aCols[nCont, nGm8DatAge])
				
				If aRValDes[1] <> 0
					Loop
				EndIf
				
				DbSelectArea("GD7")
				RecLock("GD7", .T.)
				GD7->GD7_FILIAL := xFilial("GD7")
				GD7->GD7_SEQDES := cSeqDes
				GD7->GD7_NRSEQG := cNrSeqG
				GD7->GD7_REGATE := GCY->GCY_REGATE
				GD7->GD7_CODLOC := oGDGm8:aCols[nCont, nGm8CodLoc]
				GD7->GD7_CODDES := aProced[nContPro]
				
				GD7->GD7_HORDES := HS_DATPAT(.F.)
				GD7->GD7_DATDES := oGDGm8:aCols[nCont, nGm8DatAge]//HS_DATPAT(.T.)
				
				GD7->GD7_CODCRM := oGDGm8:aCols[nCont, nGm8CodCrm]
				
				GD7->GD7_SLAUDO :=  "0"
				If HS_IsLaudo(cGcsCodLoc, aProced[nContPro])[1]
					GD7->GD7_SLAUDO :=  "1"
					GD7->GD7_CRMLAU := oGDGm8:aCols[nCont, nGm8CodCrm]
				EndIf
				
				GD7->GD7_QTDDES := 1
				GD7->GD7_LOGARQ := HS_LOGARQ()
				
				GD7->GD7_CODPRE := aRValDes[14]
				GD7->GD7_COEFAM := aRValDes[2][1][2]
				GD7->GD7_COEDES := aRValDes[16][02]
				GD7->GD7_CODESP := aRValDes[07]
				
				GD7->GD7_URGDES := aRValDes[2][14]
				//GD7->GD7_URGDES := IIF(GBY->GBY_URGDES $ "0/1",GBY->GBY_URGDES,aRValDes[2][14])
				GD7->GD7_COECHP := aRValDes[2][10]
				GD7->GD7_QTDCHP := aRValDes[2][11]
				GD7->GD7_VLRCOS := aRValDes[2][24]
				GD7->GD7_PGTMED := aRValDes[9][1]
				GD7->GD7_COECHM := aRValDes[9][aRValDes[11]]
				GD7->GD7_REPAMB := aRValDes[9][aRValDes[10]]
				
				GD7->GD7_VALDES := aRValDes[02][01][01]
				GD7->GD7_PCUDES := aRValDes[03]
				GD7->GD7_GLODES := IIf(aRValDes[04][01], "2", "0")
				GD7->GD7_CODPRT := aRValDes[02][15]
				GD7->GD7_DESPRT := aRValDes[02][18]
				GD7->GD7_DOPLER := "0"
				
				GD7->GD7_ORIDES := "0"
				
				GD7->GD7_FATPAR := aRValDes[04][02]
				
				//If cMV_AteSus == "S" // Se atende SUS
				// If GCZ->GCZ_CODPLA == __cCodBPA // Se atende SUS e o tipo de plano eh BPA
				//  GD7->GD7_CDGATE := aRValDes[15][2][1]
				//  GD7->GD7_CDTATE := aRValDes[15][3][1]
				// EndIf
				// If GCZ->GCZ_CODPLA == __cCodBPA .Or. GCZ->GCZ_CODPLA == __cCodPAC  // Se atende SUS e eh BPA ou APAC
				//  GD7->GD7_CDAPRO := aRValDes[15][1][1]
				//  GD7->GD7_CODCID := aRValDes[15][4][1]
				// EndIf
				//EndIf
				
				If HS_ExisDic({{"C", "GD7_VALREB"}},.F.)
					GD7->GD7_VALREB := GD7->GD7_QTDDES * aRValDes[9][14]
					GD7->GD7_VALREP := GD7->GD7_QTDDES * aRValDes[9][14]
				Else
					GD7->GD7_VALREP := GD7->GD7_QTDDES * aRValDes[9][14]
				EndIf
				
				If HS_ExisDic({{"C", "GD7_VLREPF"}},.F.)
					GD7->GD7_VLREPF := GD7->GD7_QTDDES * aRValDes[9][17]
				EndIf
				
				GD7->GD7_VCUSOP := aRValDes[02][02]
				GD7->GD7_VFILME := aRValDes[02][03]
				GD7->GD7_VLRCOS := aRValDes[2][24]
				GD7->GD7_CODPRE := aRValDes[14]
				
				If Hs_ExisDic({{"C", "GD7_TABELA"}}, .F.)
					GD7->GD7_TABELA := aRValDes[02][20]
				EndIf
				
				MsUnLock()
				
			Next
			
			Fs_M12GrMM(oGDGm8:aCols[nCont, nGm8DatAge], GCY->GCY_REGATE, oGDGm8:aCols[nCont, nGm8CodPla],oGDGm8:aCols[nCont, nGm8CodLoc])
			
			DbSelectArea("GM8")
			DbSetOrder(12) //GM8_FILIAL+GM8_AGDPRC
			If DbSeek(xFilial("GM8") + oGDGm8:aCols[nCont, nGm8CodAge])
				
				While GM8->(!Eof()) .And. GM8->GM8_FILIAL = xFilial("GM8") .And. GM8->GM8_AGDPRC == oGDGm8:aCols[nCont, nGm8CodAge]
					RecLock("GM8", .F.)
					GM8->GM8_STATUS := "3" // Atendido
					GM8->GM8_REGATE := GCY->GCY_REGATE
					MsUnLock()
					DbSkip()
				EndDO
				
			EndIf
			
		EndIf
	Next
EndIf
RestArea(aArea)
Return(lRet)


Static Function Fs_UltDat()
Local dRet  := CtoD("")
Local aCols := {}
Local nCont := 0

aCols := aClone(oGDGm8:aCols)

aSort(aCols ,,,{|x,y| x[nGm8DatAge] > y[nGm8DatAge]})

for nCont := 1 to len(aCols)
	if aCols[nCont, nGm8Status] == "BR_PINK"
		dRet := aCols[nCont, nGm8DatAge]
		exit
	endIf
next

Return(dRet)

Static Function Fs_M12GrMM(dDatAge, cRegAte, cCodPla, cCodLoc)
Local lRet    := .T.
Local aArea   := getArea()
Local dUltDat := CtoD("")
Local cSql    := ""
Local aHMM    := {}, aCMM := {}, nUMM := 0
Local nCont   := 0
Local cCpoNaoMM := " GD5_CODLOC/GD5_NOMLOC/GD5_DESPER/GD5_DESVAL/GD5_VALDES/GD5_DESOBS/GD5_VALTOT/GD5_TOTDSC/GD5_PGTMED/GD5_REPAMB/GD5_REPINT/GD5_CODPRE/GD5_VALREP/GD5_NREXTM/GD5_VLRGLO/GD5_VLRREC/GD5_STATUS/GD5_DATSTA/GD5_HORSTA/GD5_VALREB/ "
Local aDespExcec := {}

Local aVarDef := {{"cGcsCodLoc"   , "GCS->GCS_CODLOC"}, ;
{"cGcsCodCCu"   , "GCS->GCS_CODCCU"}, ;
{"cGcsArmSet"   , "GCS->GCS_ARMSET"}, ;
{"cGcsArmFar"   , "GCS->GCS_ARMFAR"}}

Private nMMStaReg := 0, nMMQDevol := 0, nMMCodLoc := 0, nMMNomLoc := 0
Private nMMDatDes := 0, nMMHorDes := 0, nMMSeqDes := 0, nMMQtdDes := 0
Private nMMCODDES := 0, nMMCODBAR := 0, nMMDDESPE := 0, nMMNumLot := 0
Private nMMLoteFo := 0, nMMLoteCt := 0, nMMDtVali := 0, nMMProAlt := 0
Private nMMDPrAlt := 0, nMMCodPct := 0, nMMDesPct := 0, nMMCodKit := 0
Private nMMDesKit := 0, nMMValDes := 0, nMMPCuDes := 0, nMMCodPro := 0
Private nMMDesPro := 0, nMMTABELA := 0, nMMUNICON := 0, nMMDESPER := 0
Private nMMDESVAL := 0, nMMDESOBS := 0, nMMVALTOT := 0, nMMTOTDSC := 0
Private nMMCODCRM := 0, nMMNOMMED := 0, nMMPGTMED := 0, nMMREPAMB := 0
Private nMMREPINT := 0, nMMVALREP := 0, nMMNREXTM := 0, nMMVLRGLO := 0
Private nMMVALREB := 0
Private cLctCodLoc := ""

//Rodar Hs_BDados , alterar campos de data, hora e status e gravar com funcao do M24
HS_BDados("GD5", @aHMM, @aCMM,@nUMM, 4,, '0 = 1 ', .T.,,,, cCpoNaoMM,,,,,, .T.,,,, {"GD5_QDEVOL"})
nMMStaReg := aScan(aHMM, {|aVet| aVet[2] == "HSP_STAREG"})
nMMQDevol := aScan(aHMM, {|aVet| aVet[2] == "GD5_QDEVOL"})
nMMCodLoc := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODLOC"})
nMMNomLoc := aScan(aHMM, {|aVet| aVet[2] == "GD5_NOMLOC"})
nMMDatDes := aScan(aHMM, {|aVet| aVet[2] == "GD5_DATDES"})
nMMHorDes := aScan(aHMM, {|aVet| aVet[2] == "GD5_HORDES"})
nMMSeqDes := aScan(aHMM, {|aVet| aVet[2] == "GD5_SEQDES"})
nMMQtdDes := aScan(aHMM, {|aVet| aVet[2] == "GD5_QTDDES"})
nMMCODDES := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODDES"})
nMMCODBAR := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODBAR"})
nMMDDESPE := aScan(aHMM, {|aVet| aVet[2] == "GD5_DDESPE"})
nMMNumLot := aScan(aHMM, {|aVet| aVet[2] == "GD5_NUMLOT"})
nMMLoteFo := aScan(aHMM, {|aVet| aVet[2] == "GD5_LOTEFO"})
nMMLoteCt := aScan(aHMM, {|aVet| aVet[2] == "GD5_LOTECT"})
nMMDtVali := aScan(aHMM, {|aVet| aVet[2] == "GD5_DTVALI"})
nMMProAlt := aScan(aHMM, {|aVet| aVet[2] == "GD5_PROALT"})
nMMDPrAlt := aScan(aHMM, {|aVet| aVet[2] == "GD5_DPRALT"})
nMMCodPct := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODPCT"})
nMMDesPct := aScan(aHMM, {|aVet| aVet[2] == "GD5_DESPCT"})
nMMCodKit := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODKIT"})
nMMDesKit := aScan(aHMM, {|aVet| aVet[2] == "GD5_DESKIT"})
nMMValDes := aScan(aHMM, {|aVet| aVet[2] == "GD5_VALDES"})
nMMPCuDes := aScan(aHMM, {|aVet| aVet[2] == "GD5_PCUDES"})
nMMCodPro := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODPRO"})
nMMDesPro := aScan(aHMM, {|aVet| aVet[2] == "GD5_DESPRO"})
nMMTABELA := aScan(aHMM, {|aVet| aVet[2] == "GD5_TABELA"})
nMMUNICON := aScan(aHMM, {|aVet| aVet[2] == "GD5_UNICON"})
nMMDESPER := aScan(aHMM, {|aVet| aVet[2] == "GD5_DESPER"})
nMMDESVAL := aScan(aHMM, {|aVet| aVet[2] == "GD5_DESVAL"})
nMMDESOBS := aScan(aHMM, {|aVet| aVet[2] == "GD5_DESOBS"})
nMMVALTOT := aScan(aHMM, {|aVet| aVet[2] == "GD5_VALTOT"})
nMMTOTDSC := aScan(aHMM, {|aVet| aVet[2] == "GD5_TOTDSC"})
nMMCODCRM := aScan(aHMM, {|aVet| aVet[2] == "GD5_CODCRM"})
nMMNOMMED := aScan(aHMM, {|aVet| aVet[2] == "GD5_NOMMED"})
nMMPGTMED := aScan(aHMM, {|aVet| aVet[2] == "GD5_PGTMED"})
nMMREPAMB := aScan(aHMM, {|aVet| aVet[2] == "GD5_REPAMB"})
nMMREPINT := aScan(aHMM, {|aVet| aVet[2] == "GD5_REPINT"})
nMMVALREP := aScan(aHMM, {|aVet| aVet[2] == "GD5_VALREP"})
nMMNREXTM := aScan(aHMM, {|aVet| aVet[2] == "GD5_NREXTM"})
nMMVLRGLO := aScan(aHMM, {|aVet| aVet[2] == "GD5_VLRGLO"})
nMMVALREB := aScan(aHMM, {|aVet| aVet[2] == "GD5_VALREB"})

dUltDat := Fs_UltDat()

cSql := " SELECT "+HS_RetCpos("GD5" ,.T., ".")
cSql += " FROM "+RetSqlName("GD5")+" GD5 "
cSql += " JOIN "+RetSqlName("GCZ")+" GCZ ON GCZ_FILIAL = '"+xFilial("GCZ")+"' AND GCZ.D_E_L_E_T_ <> '*' "
cSql += "  AND GCZ_NRSEQG = GD5.GD5_NRSEQG "
cSql += " AND GCZ.GCZ_REGATE = '"+cRegAte+"' AND GCZ.GCZ_CODPLA = '"+cCodPla+"' "
cSql += " WHERE GD5_FILIAL = '"+xFilial("GD5")+"' AND GD5.D_E_L_E_T_ <> '*' AND GD5_DATDES = '"+DtoS(dUltDat)+"'"

TCQuery cSql New Alias "TMPDESP"

aCMM := {}

While TMPDESP->(!EoF())
	aAdd(aCMM,{})
	For nCont := 1 to Len(aHMM)
		cAux := nil
		If aHMM[nCont, 2] == "HSP_STAREG"
			cAux := "BR_VERMELHO"
		ElseIf aHMM[nCont, 2] == "GD5_DATDES"
			cAux := dDatAge
		ElseIf aHMM[nCont, 2] == "GD5_HORDES"
			cAux := Time()
		ElseIf aHMM[nCont, 2] == "GD5_SEQDES"
			cAux := GetSxENum("GD5","GD5_SEQDES",,1)
		ElseIf HS_CfgSx3(aHMM[nCont, 2])[SX3->(FieldPos("X3_CONTEXT"))] <> 'V'
			If HS_CfgSx3(aHMM[nCont, 2])[SX3->(FieldPos("X3_TIPO"))] <> 'D'
				cAux := &("TMPDESP->"+aHMM[nCont, 2])
			Else
				cAux := StoD(&("TMPDESP->"+aHMM[nCont, 2]))
			EndIf
		EndIf
		
		aAdd(aCMM[Len(aCMM)], cAux)
	Next
	aAdd(aCMM[Len(aCMM)], .F.)
	TMPDESP->(DbSkip())
EndDo
DbSelectArea("TMPDESP")
DbCloseArea()

cLctCodLoc := cCodLoc

RegToMemory("GCY",.F.)
HS_DefVar("GCS", 1, M->GCY_CODLOC, aVarDef)

If Len(aCMM) > 0
	HS_GrvMM("GD5", 0, .T., 7, @aDespExcec, HS_RCfgCP(Hs_IniPadr("GCM", 1, cCodPla, "GCM_CODCON",,.F.) , cCodPla, "_TIPCON"), aCMM, .F., aHMM)
EndIf

RestArea(aArea)
Return(lRet)

//Retorno da solicitação de APAC
Function Hs_SolApac(cRegAte, cCpoRet, aCposRet)
Local cRet  := ""//Space(TamSx3("GK7_NRAPAC")[1])
Local aArea := getArea()
Local cSql  := ""

cSql := " SELECT GK7.R_E_C_N_O_ " //GK7.GK7_NRAPAC "
cSql += "   FROM "+RetSqlName("GK7")+" GK7  "
cSql += "			JOIN "+RetSqlName("GM8")+" GM8 ON GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' AND GM8_CODAGE = GM8_AGDPRC "
cSql += "			 AND GK7_SEQAGE = GM8_CODAGE  AND GM8_REGATE = '"+cRegAte+"' "
cSql += "  WHERE GK7.GK7_FILIAL = '"+xFilial("GK7")+"' AND GK7.D_E_L_E_T_ <> '*' "

TCQUERY cSQL NEW ALIAS "QRYGK7"

If QRYGK7->(!Eof())
	DbSelectArea("GK7")
	DbSetOrder(1)
	DbGoTo(QRYGK7->R_E_C_N_O_)
	
	cRet := &("GK7->"+cCpoRet)
	
	If !Empty(aCposRet)
		HS_DefVar("GK7", 1, GK7->GK7_SOLICI, aCposRet)
	Endif
EndIf

QRYGK7->(DbCloseArea())

RestArea(aArea)
Return(cRet)


Function Hs_RLayApc(cCodSol, cNrSeqG)
Local cRet    := ""
Local aArea   := getArea()
Local aResp   := {}//HS_BusResp("GK8", {{"GK8->GK8_SOLICI", cCodSol}}, "PER")
Local aVet    := {}
Local nI      := 0

Default cNrSeqG := ""

If !Empty(cCodSol)
	
	DbSelectArea("GK7")
	DbSetOrder(1) //GK7_FILIAL+GK7_SOLICI
	DbSeek(xFilial("GK7")+cCodSol)
	
	aResp := HS_BusResp("GK8", {{"GK8->GK8_SOLICI", cCodSol}},"")
	
	aVet := Fs_RLayApc(Hs_IniPadr("GFS",1,GK7->GK7_CDQUES,"GFS_TIPSUS",,.F.), cNrSeqG)
	
	For nI := 1 to len(aVet)
		If     ValType(aVet[nI][1]) == "D"
			aVet[nI][1] := "DtoS("+aVet[nI][1]+")"
		ElseIf ValType(aVet[nI][1]) == "N"
			aVet[nI][1] := "str("+aVet[nI][1]+")"
		EndIf
		
		cRet += Substr(AllTrim(&(aVet[nI][1])),1,aVet[nI][2])  //IIF(Empty(&(aVet[nI])),Space(Len(&(aVet[nI]))),&(aVet[nI]))
	Next
EndIf

RestArea(aArea)
Return(cRet)

Static Function Fs_RLayApc(cTipLay, cNrSeqG)
Local aRet     := {}
Local cNrGuia  := ""
Local nQtdGuia := 0

If cTipLay == "Q"
	aRet := {{"'Q'",1},;    //APA_IDENT
	{"_SUS004",4},; //APA_CID10
	{"_SUS011",1},; //APA_LINFIN
	{"_SUS012",1},; //APA_ESTADI
	{"_SUS013",2},; //APA_GRAHIS
	{"_SUS014",8},; //APA_DTIDEN
	{"IIF(Empty(_SUS005),'N','S')",1},; //APA_TRANTE
	{"_SUS005",4},; //APA_CIDINI1
	{"DtoS(_SUS006)",8},; //APA_DTINI1
	{"_SUS007",4},; //APA_CIDINI2
	{"DtoS(_SUS008)",8},; //APA_DTINI2
	{"_SUS009",4},; //APA_CIDINI3
	{"DtoS(_SUS010)",8},;//APA_DTINI3
	{"_SUS015",1},; //APA_CONTTR
	{"DtoS(_SUS016)",8},; //APA_DTINTR
	{"SubStr(_SUS017, 1, 5)",5},; //APA_ESQUEM_P1
	{"_SUS018",3},; //APA_TOTMPL
	{"_SUS019",3},; //APA_TOTMAU
	{"_SUS001",4},; //APA_CIDPRI
	{"_SUS002",4},; //APA_CIDSEC
	{"Substr(_SUS017, len(_SUS017)-10)",10},; //APA_ESQUEM_P2
	{"Space(49)",49}} //APA_FILLER
ElseIf cTipLay == "R"
	aRet := {{"'R'",1},;     //APA_IDENT
	{"_SUS004",4},; //APA_CID10
	{"_SUS011",1},; //APA_LINFIN
	{"_SUS012",1},; //APA_ESTADI
	{"_SUS013",2},; //APA_GRAHIS
	{"_SUS014",8},; //APA_DTIDEN
	{"IIF(Empty(_SUS005),'N','S') ",1},; //APA_TRANTE
	{"_SUS005",4},;       //APA_CIDINI1
	{"DtoS(_SUS006)",8},; //APA_DTINI1
	{"_SUS007",4},;       //APA_CIDINI2
	{"DtoS(_SUS008)",8},; //APA_DTINI2
	{"_SUS009",4},;       //APA_CIDINI3
	{"DtoS(_SUS010)",8},; //APA_DTINI3
	{"_SUS015",1},;       //APA_CONTTR
	{"DtoS(_SUS016)",8},; //APA_DTINTR
	{"_SUS020",1},;       //APA_FINALI
	{"_SUS021",4},;       //APA_CIDTR1
	{"_SUS025",4},;       //APA_CIDTR2
	{"_SUS029",4},;       //APA_CIDTR3
	{"_SUS022",3},; //APA_NUMC1
	{"_SUS023",8},; //APA_INIAR1
	{"_SUS027",8},; //APA_INIAR2
	{"_SUS031",8},; //APA_INIAR3
	{"_SUS024",8},; //APA_FIMAR1
	{"_SUS028",8},; //APA_FIMAR2
	{"_SUS032",8},; //APA_FIMAR3
	{"_SUS001",4},; //APA_CIDPRI
	{"_SUS002",4},; //APA_CIDSEC
	{"_SUS026",3},; //APA_NUMC2
	{"_SUS030",3}}  //APA_NUMC3
ElseIf cTipLay == "N"
	cNrGuia  := Hs_IniPadr("GCZ",1, cNrSeqG,"GCZ_NRGUIA",,.F.)
	nQtdGuia := Hs_CountTb("GCZ"," GCZ_NRGUIA = '"+cNrGuia+"' AND GCZ_NRSEQG = '"+cNrSeqG+"' ")
	
	
	aRet := {{"'N'",1},;                                  //APA_IDENT
	{IIF(nQtdGuia == 0,"_SUS045",'Space(08)'),8},; //APA_DTPDR
	{IIF(nQtdGuia == 0,"_SUS046",'Space(03)'),3},; //APA_ALTURA
	{IIF(nQtdGuia == 0,"_SUS047",'Space(03)'),3},; //APA_PESO
	{IIF(nQtdGuia == 0,"_SUS048",'Space(04)'),4},; //APA_DIURES
	{IIF(nQtdGuia == 0,"_SUS049",'Space(04)'),4},; //APA_GLICOS
	{IIF(nQtdGuia == 0,"_SUS052",'Space(01)'),1},; //APA_ACEVAS
	{IIF(nQtdGuia == 0,"_SUS057",'Space(01)'),1},; //APA_ULSOAB
	{IIF(nQtdGuia <> 0,"_SUS058",'Space(04)'),4},; //APA_TRU
	{IIF(nQtdGuia <> 0,"_SUS061",'Space(02)'),2},; //APA_INTFIS
	{IIF(nQtdGuia <> 0,"_SUS062",'Space(01)'),1},; //APA_CNCDO
	{"_SUS060",2},; //APA_ALBUMI
	{"_SUS064",1},; //APA_HCV
	{"_SUS065",1},; //APA_HBSAG
	{"_SUS063",1},; //APA_HIV
	{"_SUS059",2},; //APA_HB
	{"_SUS001",4},; //APA_CIDPRI
	{"_SUS002",4},; //APA_CIDSEC
	{"Space(94)",94}} //APA_FILLER
ElseIf cTipLay == "B"
	aRet := {{"'B'",1},;     //APA_IDENT
	{"_SUS033",3},; //APA_IMC
	{"_SUS035",10},; //APA_PROCAIH
	{"_SUS036",8},; //APA_DTCIRURG
	{"_SUS034",13},; //APA_NUMAIH
	{"_SUS038",10},; //APA_PROCAIH2
	{"_SUS039",10},; //APA_PROCAIH3
	{"_SUS037",13},; //APA_NUMAIH2
	{"_SUS040",8},; //APA_DTCIRURG2
	{"_SUS041",2},; //APA_MESACOMP
	{"_SUS042",4},; //APA_ANOACOMP
	{"_SUS043",1},; //APA_PONTBARR
	{"_SUS044",1}} //APA_TABBARR
EndIf

Return(aRet)


//Local lBloqueia := Hs_IniPadr("GM7", 1, M->GM8_MOTIVO, "GM7_IDEBLO",,.F.) # "0"
Static Function Fs_BloqGM8(cCodAge, cMotivo, cOriCan)
Local aArea := getArea()
Local lBloqueia := Hs_IniPadr("GM7", 1, cMotivo, "GM7_IDEBLO",,.F.) # "0"
Local lAviso	:= 	HS_INIPADR("GM7", 1, cMotivo, "GM7_AVISO",, .F.) == "1" // Verifica se o mesmo avisou o cancelamento apos 24 horas

DbSelectArea("GM8")
DbSetOrder(1)

If DbSeek(xFilial("GM8")+cCodAge) .AND. (GM8->GM8_MOTIVO <> cMotivo .OR. GM8->GM8_ORICAN <> cOriCan)
	RecLock("GM8",.F.)
	If lAviso
		GM8->GM8_STATUS := "4"
		GM8->GM8_ORICAN := cOriCan
		GM8->GM8_MOTIVO	:= cMotivo
		GM8->GM8_LOGARQ := HS_LogArq()
	Else
		If lBloqueia
			GM8->GM8_STATUS := "2" //Bloqueado
			GM8->GM8_ORICAN := cOriCan //Grava o Tipo de Cancelamento somente no Bloqueio
			GM8->GM8_REGGER := " "
			GM8->GM8_MATRIC := " "
			GM8->GM8_NOMPAC := " "
			GM8->GM8_TELPAC := " "
			GM8->GM8_CODPLA := " "
			GM8->GM8_SQCATP := " "
			GM8->GM8_CODCON := " "
			GM8->GM8_CODPRO := " "
			GM8->GM8_OBSERV := " "
			GM8->GM8_CODUSU := " "
			GM8->GM8_LOCAGE := " "
		Else
			If GM8->GM8_TIPAGE == "1" //Encaixe
				GM8->GM8_HORAGE := "  :  "
			EndIf
			GM8->GM8_REGGER := " "
			GM8->GM8_MATRIC := " "
			GM8->GM8_NOMPAC := " "
			GM8->GM8_TELPAC := " "
			GM8->GM8_CODPLA := " "
			GM8->GM8_CODCON := " "
			GM8->GM8_CODPRO := " "
			GM8->GM8_OBSERV := " "
			GM8->GM8_CODUSU := " "
			If GM8->GM8_STATUS == "4"
				GM8->GM8_STATUS := "2"
			Else
				GM8->GM8_STATUS := "0"
			Endif
			GM8->GM8_DATCAD := Ctod("")
			GM8->GM8_HORCAD := " "
			GM8->GM8_CODUSU := " "
			GM8->GM8_DESCFM := " "
			GM8->GM8_DATCFM := Ctod("")
			GM8->GM8_HORCFM := " "
			GM8->GM8_USUCFM := " "
			GM8->GM8_LOCAGE := " "
		EndIf
		
		GM8->GM8_DURACA := SPACE(TamSx3("GM8_DURACA")[1])
		GM8->GM8_INTERV := 0
		GM8->GM8_NUMSES := 0
		GM8->GM8_PROTOC := SPACE(TamSx3("GM8_PROTOC")[1])
		GM8->GM8_AGDPRC := SPACE(TamSx3("GM8_AGDPRC")[1])
		GM8->GM8_MOTIVO	:= cMotivo
		GM8->GM8_LOGARQ := HS_LogArq()
	EndIf
	MsUnLock()
EndIf

RestArea(aArea)

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_A120PEDº Autor ³ Rogerio Tabosa     º Data ³  07/06/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamada da rotina de Pedido de Compra do Compras(MATA120)  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_A120PED(nOpc)
Local aArea		:= getArea()
Local nOpcPed	:= 0
Local nRegSC7	:= 0

If !Hs_ExisDic({{"C","GK7_NUMPED","FNC 00000005496/2011"}})
	Return(Nil)
EndIf

If !Empty(M->GK7_NUMPED)
	DbSelectArea("SC7")
	DbSetOrder(1)
	If DbSeek(xFilial("SC7") + M->GK7_NUMPED)
		nRegSC7 := SC7->(RecNo())
		nOpcPed := A120Pedido("SC7",nRegSC7,IIf(nOpc == 3 .OR. Alltrim(M->GK7_STATUS) $ "12",2,nOpc))
	Else
		M->GK7_NUMPED := Space(TamSx3("C7_NUM")[1])
		Hs_MsgInf(STR0001,STR0013, STR0002)     //"Pedido não encontrado!""Atenção""Validação Solicitação de APAC"
		Return(Nil)
	EndIf
ElseIf nOpc == 3
	
	nOpcPed := A120Pedido("SC7",1,3)
	
	If nOpcPed == 1 .AND. IIF(Type("SC7->C7_NUM") # "U",!Empty(SC7->C7_NUM), .F.)
		M->GK7_NUMPED := SC7->C7_NUM
		oEnGK7:Refresh()
	EndIf
Else
	M->GK7_NUMPED := Space(TamSx3("C7_NUM")[1])
	Hs_MsgInf(STR0001,STR0013, STR0002)     //"Pedido não encontrado!""Atenção""Validação Solicitação de APAC"
EndIf

RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M12EACBº Autor ³ Rogerio Tabosa     º Data ³  13/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Envia ou Autoriza a Solicitação Via Codigo de Barras       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_M12EACB(cProc)

Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}
Local cCodSol	:= Space(TamSx3("GK7_SOLICI")[1])
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlg TITLE IIf(cProc == "E",STR0056,STR0057) From 120, 000 To 244 , 239 Of oMainWnd Pixel //"Envia Solicitação","Autoriza Solicitação"

@ aPObjs[1,1], 020 Say STR0058 Of oDlg Pixel COLOR CLR_BLUE  //"Codigo da Solicitação"
@ aPObjs[1,1]+10, 020 MsGet oSol VAR cCodSol Size 80, 009 OF oDlg Pixel COLOR CLR_BLACK
oBtnEnv := tButton():New(@ aPObjs[1,1]+25, 035, STR0059, oDlg, {|| Processa({||FS_CODBAR(cCodSol, cProc),cCodSol := Space(TamSx3("GK7_SOLICI")[1]),oSol:SetFocus()})}, 050, 012,,,, .T.)    //"Confirma"

ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg, {||nOpca := 1, oDlg:End()}, {|| nOpca := 0, oDlg:End()},, aButtons)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CODBAR º Autor ³ Rogerio Tabosa     º Data ³  13/09/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza o Status da Solicitação Via Codigo de Barras      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_CODBAR(cSolici, cProc)
Local aStatus :=  {	{0, "Solicitada"},;
{1 ,"Aguardando Autorização"},;
{2 ,"Autorizada"},;
{3 ,"Agendada"},;
{4 ,"Devolvida"},;
{5, "Cancelada"}}

If Empty(cSolici)
	HS_MSGINF(STR0055,STR0013, STR0002) //"Informe o numero da Solicitação!""Atenção","Validação Solicitação APAC"
	Return()
EndIf

DbSelectArea("GK7")
DbSetOrder(1)
If DbSeek(xFilial("GK7") + cSolici)
	If cProc == "E"  //Envia Solicitação
		If GK7->GK7_STATUS <> "0"
			HS_MSGINF(STR0060 + aStatus[Val(GK7->GK7_STATUS)+1,2]  + STR0061,STR0013, STR0002) //"A Solicitação encontra-se no status [""], envio não efetuado!""Atenção","Validação Solicitação APAC"
			Return()
		EndIf
		RecLock("GK7", .F.)
		GK7->GK7_STATUS := '1'
		MsUnLock()
	Else //Autoriza Solicitação
		If GK7->GK7_STATUS <> "1"
			HS_MSGINF(STR0060 + aStatus[Val(GK7->GK7_STATUS)+1,2]  + STR0062,STR0013, STR0002) //"A Solicitação encontra-se no status ["], autorização não efetuada!"""Atenção","Validação Solicitação APAC"
			Return()
		EndIf
		RecLock("GK7", .F.)
		GK7->GK7_STATUS := '2'
		MsUnLock()
	EndIf
Else
	HS_MSGINF("Solicitação não encontrada!",STR0013, STR0002) //"Solicitação não encontrada!""Atenção","Validação Solicitação APAC"
	Return()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSXB ºAutor  ³Darcio Ribeiro Sporlº Data ³  18/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para ajustar a consulta padrao GBJ.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSXB()
Local aArea := GetArea()

DbSelectArea("SXB")
DbSetOrder(1)
If DbSeek("GBJ   ")
	While SXB->(!Eof()) .And. XB_ALIAS == "GBJ   "
		If Empty(XB_TIPO)
			RecLock("SXB", .F.)
				SXB->(DbDelete())
			SXB->(MsUnLock())
		EndIf
		SXB->(DbSkip())
	End
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RelatSuºAutor  ³ Saude              º Data ³  22/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao desenvolvida, para selecao de formularios SUS para   º±±
±±º          ³impressao                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_relatSu()

Local aRelat	:= {}		// Vetor utilizado para trazer os relatorios disponiveis
Local nOpcI		:= 2
Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local cTitulo	:= STR0046 //"Relatórios SUS"
Local aOrd		:= {STR0047, STR0048}//'Código' , 'Descrição'
Local oButton
Local nI  
Local oCheck,lCheck1 
Local lChecked

//Relatorios disponiveis
aAdd(aRelat,{lMark,STR0049,"HSPR8801()",1}) //"CONTROLE DE FREQUÊNCIA INDIVIDUAL DEFICIÊNCIA FÍSICA"
aAdd(aRelat,{lMark,STR0050,"HSPR8802()",2}) //"LAUDO MÉDICO PARA EMISSÃO DE APAC DE REABILITAÇÃO FÍSICA"
aAdd(aRelat,{lMark,STR0051,"HSPAHR96()",3})	 //"CONTROLE DE FREQUÊNCIA INDIVIDUAL DE PACIENTE COM DEFICIÊNCIA AUDITIVA"	
aAdd(aRelat,{lMark,STR0052,"HSPAHR97()",4}) //"LAUDO PARA EMISSÃO DE APAC DEFICIÊNCIA AUDITIVA"


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 250,500 PIXEL


oCheck := TCheckBox():New(110,120,STR0063,,oDlg,100,210,,,,,,,,.T.,,,)//"Selecionar Todos"
oCheck:bLClicked := {|| lCheck1:=!lCheck1,hs_nois(@oLbx,@aRelat,@lCheck1,@oCheck) }//Linha nova
@ 10,10 LISTBOX oLbx FIELDS HEADER 	"", STR0053 SIZE 230,095 OF oDlg PIXEL ON DblClick(;
	iIf(aRelat[oLbx:nAt,1]==.F.,;
		aRelat[oLbx:nAt,1]:=.T.,;
		(aRelat[oLbx:nAt,1]:=.F.,oCheck:bSetGet:= {|| .F.},oCheck:refresh()));  //		//aRelat[oLbx:nAt,1]:=.F.);
		,oLbx:Refresh() )//"Relatório"

	oLbx:SetArray( aRelat )
  	oLbx:bLine := {|| {Iif(aRelat[oLbx:nAt,1],oOk,oNo),;
						    aRelat[oLbx:nAt,2],;
	  					    aRelat[oLbx:nAt,3]}} 
	  					    

DEFINE SBUTTON FROM 110,180 TYPE 1 ACTION {|| nOpcI := 1, oDlg:End()} ENABLE OF oDlg	//Ok
DEFINE SBUTTON FROM 110,210 TYPE 2 ACTION {|| nOpcI := 2, oDlg:End()} ENABLE OF oDlg	//Cancelar
ACTIVATE MSDIALOG oDlg CENTER

If nOpcI == 1
	for nI=1 to len(aRelat)
		if aRelat[nI,1]==.T.
			&(aRelat[nI,3])
		endif
	next nI
	return(nil)
EndIf

Return(nil)  


function hs_nois(oList,aVetor,lChecado,oCheckB)//Linha nova
Local nI:=1
if lChecado
	//Atualiza todas as linhas como .T.
	for nI=1 to len(aVetor)
		aVetor[nI,1]:=.T.  
  	next nI
    //Seta o checkbox como checked e atualiza
    oCheckB:bSetGet:= {|| .T.}
    oCheckB:refresh()
else  
	//Atualiza todas as linhas como .F.
	for nI=1 to len(aVetor)
		aVetor[nI,1]:=.F.  
	next nI
    //Seta o checkbox como unchecked e atualiza
    oCheckB:bSetGet:= {|| .F.}
    oCheckB:refresh()
endif
oList:refresh()
return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_CidApacºAutor  ³ Saude              º Data ³  22/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o CID do paciente para geracao do arquivo magnetico º±±
±±º          ³APAC                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function HS_CidApac(cSolici,cTipCID,cNRSEQG) 
Local cRet      := ""            
Local cRegistro := ""
Local aArea     := GetArea()

Do Case 
   Case cTipCID == "PAP_CIDP0"   
       cRegistro := "SUS001"
   Case cTipCID == "PAP_CIDS0" 
       cRegistro := "SUS002"
   Case cTipCID == "APA_CIDCA"  
       cRegistro := "SUS003"
EndCase        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica CID no Questionario                              		     	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
GK8->(DbSetOrder(1))//GK8_FILIAL+GK8_SOLICI+GK8_CDQUES+GK8_GRPPER+GK8_CODPER
If GK8->(DbSeek(xFilial("GK8")+cSolici))
	While GK8->GK8_SOLICI == cSolici .And. !GK8->(Eof())
		If cRegistro == GK8->GK8_CODPER
			cRet := GK8->GK8_RESCAR
			Exit
		EndIf 
		GK8->(DbSkip())
	EndDo
EndIf      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao achou no questionario, verifica CID´s do atendimento		     	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If Empty(cRet)
	GCZ->(DbSetOrder(1))//GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
	If GCZ->(DbSeek(xFilial("GCZ")+cNRSEQG))
		GCY->(DbSetOrder(1))//GCY_FILIAL+GCY_REGATE
		If GCY->(DbSeek(xFilial("GCY")+GCZ->GCZ_REGATE))
			Do Case
				Case cTipCID == "PAP_CIDP0"
					cRet := GCY->GCY_CIDINT
				Case cTipCID == "PAP_CIDS0"
					cRet := GCY->GCY_CIDCMP
			EndCase
		EndIf
	EndIf
EndIf

RestArea(aArea) 
Return(cRet)