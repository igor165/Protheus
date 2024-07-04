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
±±ºPrograma  ³HSPAHM13  º Autor ³ Sueli C Santos     º Data ³  25/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Solicitação Terapia                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM13()

Local aCorM13 := {	{"GKB->GKB_STATUS == '0' " , "BR_VERDE"},;
					{"GKB->GKB_STATUS == '1' " , "BR_AMARELO"},;
					{"GKB->GKB_STATUS == '2' " , "BR_AZUL"},;
					{"GKB->GKB_STATUS == '3' " , "BR_LARANJA"},;
					{"GKB->GKB_STATUS == '4' " , "BR_VERMELHO"},;
					{"GKB->GKB_STATUS == '5' " , "BR_CINZA"}}
Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM13(.T.)})

Private aRotina    := {}
Private __cProntu  := ""  //Utilizado Filtro GCY
Private __cGStatus := "0" //Utilizado Filtro GCY
Private cSusProIns := ""//Utilizado Filtro GA7
Private cCadastro  := "Solicitação"
Private cGBJTipPro := ""
Private cFilM13    := ""

Private cCodProSus := "" //Utilizado Filtro GAS

If !Hs_ExisDic({{"T", "GKB"}})
	Return(Nil)
EndIf

//Se UPDGH110 foi executado (permitir agendamento multiplo) adiciona status "6"
if SuperGetMv("MV_AGDMSES",nil,.F.)
	aAdd(aCorM13,{"GKB->GKB_STATUS == '6' " , "BR_MARRON"})
endif

aAdd(aRotina, {"Pesquisar" ,"AxPesqui" , 0, 1, 0, nil})
aAdd(aRotina, {"Visualizar","HS_M13ROT", 0, 2, 0, nil})
aAdd(aRotina, {"Solicitar","HS_M13ROT", 0, 3, 0, nil})
aAdd(aRotina, {"Alterar"  ,"HS_M13ROT", 0, 4, 0, nil})
aAdd(aRotina, {"Devolver" ,"HS_M13DEV", 0, 4, 0, nil})
If Hs_ExisDic({{"C","GKB_SEQAGE"}},.F.)
	aAdd(aRotina, {"Agendar"  ,"HS_M13AGD", 0, 4, 0, nil})
EndIf
aAdd(aRotina, {"Legenda"  ,"HS_M13LEG", 0, 4, 0, nil})

AjustaSXB()

DbSelectArea("GK8")
DbSelectArea("GKB")
DbSetOrder(1)       

If FS_FilM13(.F.)
	mBrowse(06, 01, 22, 75, "GKB", , , , , , aCorM13,,,,,,,, cFilM13)
EndIf

SetKey(VK_F12, bKeyF12)

Return(nil)
	
Function Hs_M13ROT(cAlias, nReg, nOpc)
Local aSvKeys		:= GetKeys()
Local nI       := 0
Local cOldVar  := ""
Local aButtons := {}
Local aCpos    := {}
Local lDev := IIF(Type("lDevolve") # "U",lDevolve, .F.)
Local nOpcGd   := IIF(nOpc == 3 .Or. nOpc == 4, GD_INSERT+GD_UPDATE+GD_DELETE, 0)

Private oEnGKB, oEnGK8
Private aTela   := {}, aGets := {}, aSTela := {{},{}}, aSGets := {{},{}}
Private cTab := "", aPGets := {}
Private cTabSel := ""
Private nOpcDlg := 0
Private aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Private aTelaQues := {}
Private aMntperg := {}
Private oPnlGk8
Private nOpcE   := aRotina[nOpc, 4]
Private cCdQues := GKB->GKB_CDQUES

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
DbSeek("GKB")
While SX3->(!Eof()) .And. X3_ARQUIVO == "GKB"
	If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. (!SX3->X3_CAMPO $ "GKB_CODMOT/GKB_DESMOT" .Or. lDev)
		Aadd(aCpos, SX3->X3_CAMPO)
	EndIf
	DbSkip()
EndDo

RegToMemory("GKB", nOpcE == 3)
M->GKB_CDQUES := cCdQues
HS_SeekRet("GFS", "M->GKB_CDQUES", 1, .F., "GKB_DSQUES", "GFS_DSQUES",,, .T.)

If nOpcE # 2 .And. (M->GKB_STATUS $ "0/1/4")
	aAdd(aButtons,	{"S4WB001N", {|| Hs_M13Conf()}, "Confirmar"})
EndIf

HS_BDados("GKA", @aHGKA, @aCGKA, @nUGKA, 1,, " GKA->GKA_SOLICI = '"+M->GKB_SOLICI+"'")//, .T.)

nGKACODITE := aScan(aHGKA, {| aVet | aVet[2] == "GKA_CODITE"})
nGKACODPRO := aScan(aHGKA, {| aVet | aVet[2] == "GKA_CODPRO"})
nGKADESPRO := aScan(aHGKA, {| aVet | aVet[2] == "GKA_DESPRO"})
If Empty(aCGKA[1, nGKACODITE])
	aCGKA[1, nGKACODITE]	:= StrZero(1, Len(aCGKA[1, nGKACODITE]))
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel

oEnGKB := MsMGet():New("GKB" ,nReg ,nOpc,,,, aCpos  , {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,,oDlg,,.F.)
oEnGKB:oBox:align := CONTROL_ALIGN_TOP

//		oEnGKB:AENTRYCTRLS[aScan(oEnGKB:aGets, {| aVet | "GKB_CRMAUT" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := "8"}

oEnGKB:AENTRYCTRLS[aScan(oEnGKB:aGets, {| aVet | "GKB_CRMSOL" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := ""}
oEnGKB:AENTRYCTRLS[aScan(oEnGKB:aGets, {| aVet | "GKB_CRMRES" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := ""}
oEnGKB:AENTRYCTRLS[aScan(oEnGKB:aGets, {| aVet | "GKB_CRMEXC" $ aVet})]:BGOTFOCUS := {|| cGBJTipPro := ""}

oEnGKB:AENTRYCTRLS[aScan(oEnGKB:aGets, {| aVet | "GKB_CODPRO" $ aVet})]:BGOTFOCUS := {|| cSusProIns := Nil}

//aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4]
oFolder := TFolder():New(aPObjs[2, 1], aPObjs[2, 2],{"Laudo","Procedimentos"},{"Laudo","Procedimentos"},oDlg,,,,.T.,.F.,aPObjs[2, 3], aPObjs[2, 4])
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

If(nOpcE # 3)
	HS_BusResp("GK8", {{"GK8->GK8_SOLICI", GKB->GKB_SOLICI},{"GK8->GK8_CDQUES", GKB->GKB_CDQUES}}, "PER")
Endif

aMntperg := HS_MntPerg(cCdQues, oFolder:aDialogs[1]/*oDLg*/,, aPGets[1], nOpcE == 2 .Or. !(M->GKB_STATUS $ '0/4'), "PER" , "oEncQues",, "aTelaQues", CONTROL_ALIGN_ALLCLIENT,, "G", .T.)

oGKA := MsNewGetDados():New(aPGets[1, 1],aPGets[1, 2], aPGets[1, 3],aPGets[1, 4], nOpcGd,,,"+GKA_CODITE",,,99999,,,, oFolder:aDialogs[2], aHGKA, aCGKA)
oGKA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGKA:oBrowse:bGotFocus :=  {|| cSusProIns := Nil}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets,aTela) .And. HS_ObrgPer(aMntPerg[3], aMntPerg[2]), oDlg:End(), nOpcDlg := 0)}, ;
{|| nOpcDlg := 0, oDlg:End()},,aButtons)

If nOpcDlg == 1 .And. nOpcE # 2
	Begin Transaction
	Fs_M12Grv("GKB", M->GKB_SOLICI,aRotina[nOpc, 4] == 5, lDev)
	HS_GrvResp("GK8", {{"GK8->GK8_SOLICI", M->GKB_SOLICI}, {"GK8->GK8_CDQUES", cCdQues}} , aMntperg[2])
	End Transaction
Else
	While __lSx8
		RollBackSxe()
	End
EndIF

MBrChgLoop(.F.)
RestKeys( aSvKeys , .T. )
Return(nil)
							
Function HS_M13DEV(cAlias, nReg, nOpc)
private lDevolve := .T.

If GKB->GKB_STATUS == '1'
	Hs_M13Rot(cAlias, nReg, nOpc)
Else
	Hs_MsgInf("Opção inválida para solicitação ["+GKB->GKB_SOLICI+"]","Atenção","Validação Devolução")
EndIf

Return(nil)

Function Hs_M13Conf()

nOpcDlg := 0

If !(Obrigatorio(aGets,aTela) .And. HS_ObrgPer(aMntPerg[3], aMntPerg[2]))
	Return(nil)
EndIF

If M->GKB_STATUS == "0" .And. !Empty(M->GKB_NRAUT)
	M->GKB_STATUS := Soma1(M->GKB_STATUS)
ElseIf M->GKB_STATUS == "1" .And. Empty(M->GKB_NRAUT)  .And. !MsgYesNo("Não informado número da Autorização."+chr(13)+"Deseja prosseguir?")
	Return(nil)
ElseIf M->GKB_STATUS == "4"
	M->GKB_STATUS := "0"
EndIf

M->GKB_STATUS := Soma1(M->GKB_STATUS)
nOpcDlg := 1
oDlg:End()

Return(nil)

Static Function Fs_M12Grv(cAliasGrv, cSolici, lExclui, lDev)
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
	
	If lDev .And. cAliasGrv == "GKB"
		GKB->GKB_STATUS := IIF(Hs_IniPadr("GK9", 1, M->GKB_CODMOT, "GK9_RETMOT") == "1","4","5")
	EndIf
Else
	DbDelete()
EndIf
MsUnLock()

for nI := 1 to len(oGKA:aCols)
	
	If Empty(oGKA:aCols[nI, nGKACodPro])
		Loop
	EndIF
	
	DbSelectArea("GKA")
	DbSetOrder(1)
	lAchou := DbSeek(xFilial("GKA")+M->GKB_SOLICI+oGKA:aCols[nI, nGKACodIte])
	
	If lExclui .And. !lAchou
		Loop
	EndIf
	
	RecLock("GKA",!lAchou)
	
	If !lExclui
		GKA_FILIAL := xFilial("GKA")
		GKA_SOLICI := M->GKB_SOLICI
		GKA_CODITE := oGKA:aCols[nI, nGKACodIte]
		GKA_CODPRO := oGKA:aCols[nI, nGKACodPro]
	Else
		DbDelete()
	EndIf
	
	MsUnLock()
	
Next

ConfirmSx8()

Return(nil)
		
Function HS_M13AGD()
Local cSeqAge := ""
Local lOldInc := Inclui
Local lOldAlt := Altera
Local lAtuAgd := getMv("MV_LAPACSN",,.F.)
Local lAgdmSes   := SuperGetMv("MV_AGDMSES",nil,.F.)
Local lHspahm13  := isInCallStack("HSPAHM13")
Local cCodSolGkb := ""
Local lGm8SolGkb := Hs_ExisDic({{"C","GM8_SOLGKB"}}, .F.)


Private lCopiar := .T.
Private bCopia     := {|| Hs_M13CAgd() }
Private cGcsCodLoc := "" //Setor selecionado
Private aRotina    := {{"" ,"" , 0, 3, 0, nil},;
{"" ,"" , 0, 3, 0, nil},;
{"" ,"" , 0, 3, 0, nil}}

If !Hs_ExisDic({{"C","GKB_SEQAGE"}},.F.) .Or. GKB->GKB_STATUS > '3' .and. GKB->GKB_STATUS <> '6'
	MsgAlert("Opção não disponível")
ElseIf GKB->GKB_STATUS < '2' .And. !lAtuAgd
	MsgAlert("Opção inválida para solicitação ["+GKB->GKB_SOLICI+"]")
Else
	//If Empty(GKB->GKB_SEQAGE)
	If Empty(GKB->GKB_SEQAGE) .or. GKB->GKB_STATUS == "6"//Agendado / Agend. Permitido
		If HSPM29Perg()
			Inclui  := .T.
			lAltera := .F.
			DbSelectArea("GM8")
			cSeqAge := HSPM29Atu('GM8', GM8->(RecNo()), 2)
			
			If !Empty(cSeqAge)
				RecLock("GKB", .F.)
					If empty(GKB->GKB_SEQAGE)
						GKB->GKB_SEQAGE := cSeqAge
					Endif
				//Se existe agendamento multiplo e  a quantidade de sessoes atingiu a quantidade maxima de procedimentos permitidos na solicitacao
				if lAgdmSes .and. !empty(GKB->GKB_SEQAGE)
					if hs_qtProAg( GKB->GKB_SOLICI, GKB->GKB_CODPRO, "S" ) ==  GKB->GKB_QTDSOL
						GKB->GKB_STATUS := '3'
					else
						GKB->GKB_STATUS := '6'
					endif							
				elseif !empty(GKB->GKB_SEQAGE)
					GKB->GKB_STATUS := '3'				
				endif
				MsUnLock()
			EndiF
			Inclui := lOldInc
			Altera := lOldAlt
		EndIf
	Else
		Fs_ExbAgSe(GKB->GKB_SOLICI)
	EndIf
EndIf

Return(nil)

//Função utilizada para carregar variaveis de memoria da agenda
Function Hs_M13CAgd()
Local aVar := {	{"GM8_REGGER","GM8REGGER"},{"GM8_NOMPAC","GM8NOMPAC"},{"GM8_MATRIC","GM8MATRIC"},{"GM8_TELPAC","GM8TELPAC"},;
				{"GM8_CODPLA","GM8CODPLA"},{"GM8_SQCATP","GM8SQCATP"},{"GM8_CODPRO", "GM8CODPRO"},{"GM8_CODCRM","GM8CODCRM"}}
Local nCont := 0
Local cValid := ""

Private GM8REGGER := GKB->GKB_REGGER
Private GM8NOMPAC := Space(TamSx3("GBH_NOME")[1])
Private GM8MATRIC := Space(TamSx3("GM8_MATRIC")[1])
Private GM8TELPAC := Space(TamSx3("GM8_TELPAC")[1])
Private GM8CODPLA := Space(TamSx3("GM8_CODPLA")[1])
Private GM8SQCATP := Space(TamSx3("GM8_SQCATP")[1])
Private GM8CODPRO := GKB->GKB_CODPRO
Private GM8CODCRM := GKB->GKB_CRMEXC

HS_SeekRet("GBH", "GKB->GKB_REGGER"  ,1,.F.,{"GM8NOMPAC","GM8TELPAC"},{"GBH_NOME","GBH_TEL"})
HS_SeekRet("GD4", "GKB->GKB_REGGER+'1'",2,.F.,{"GM8MATRIC","GM8CODPLA","GM8SQCATP"},{"GD4_MATRIC","GD4_CODPLA","GD4_SQCATP"})

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
	If DbSeek(xFilial("GKA")+GKB->GKB_SOLICI)//GKA_FILIAL+GKA_SOLICI+GKA_CODITE
		
		While GKA->(!Eof()) .And. GKA->GKA_SOLICI == GKB->GKB_SOLICI
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
		
Function Fs_ExbAgSe(cSolici)
Local cSql    := ""
Local aCDados := {}
Local aHDados := {}
Local aArea   := getArea()
Local aButtons := {}
Local lAgdmSes   := SuperGetMv("MV_AGDMSES",nil,.F.)
Local lGm8SolGkb := Hs_ExisDic({{"C","GM8_SOLGKB"}}, .F.)


Private cAliasGm8 := "TMPGKB"

Aadd(aButtons, {"BR_VERDE_OCEAN", {|| HSPAHM29LEG()}, "Legenda", "Legenda"})

aSize := MsAdvSize(.T.)

cSql := " SELECT GM8_STATUS, GM8_DATAGE, GM8_HORAGE, GM8_CODSAL, GF3.GF3_DESCRI, "
cSql += "        GM8_CODREC, GNZ_DESREC, GM8_CODCRM, RA_NOME "
cSql += "  FROM "+RetSqlName("GKB")+" GKB "
cSql += "  JOIN "+RetSqlName("GM8")+" GM8 "
if !lAgdmSes .and. lGm8SolGkb
cSql += "    ON GM8.GM8_SEQAGE = GKB.GKB_SEQAGE AND GM8.GM8_CODAGE = GM8.GM8_AGDPRC "
else
	cSql += "    ON GM8.GM8_SOLGKB = GKB.GKB_SOLICI AND GM8.GM8_CODAGE = GM8.GM8_AGDPRC "
endif
cSql += "   AND GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*'  "
cSql += "  JOIN "+RetSqlName("SRA")+" SRA "
cSql += "    ON SRA.RA_FILIAL = '"+xFilial("SRA")+"' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GM8.GM8_CODCRM "
cSql += "  LEFT JOIN "+RetSqlName("GF3")+" GF3 "
cSql += "    ON GF3.GF3_FILIAL = '"+xFilial("GF3")+"' AND GF3.D_E_L_E_T_ <> '*' AND GF3.GF3_CODIGO = GM8.GM8_CODSAL "
cSql += "  LEFT JOIN "+RetSqlName("GNZ")+" GNZ "
cSql += "    ON GNZ.GNZ_FILIAL = '"+xFilial("GNZ")+"' AND GNZ.D_E_L_E_T_ <> '*' AND GNZ.GNZ_CODREC = GM8.GM8_CODREC "
cSql += " WHERE GKB.GKB_FILIAL = '"+xFilial("GKB")+"' AND GKB.D_E_L_E_T_ <> '*' "
if !lAgdmSes .and. lGm8SolGkb
cSql += "   AND GKB_SOLICI = '" + cSolici + "' "
else
cSql += "   AND GM8.GM8_SOLGKB = '" + cSolici + "' "
endif
cSql += " ORDER BY GM8_DATAGE ASC "

TCQuery cSql New Alias "TMPGKB"

While TMPGKB->(!Eof())
	aAdd(aCDados,{HSPM29SitAge()    , StoD(TMPGKB->GM8_DATAGE),TMPGKB->GM8_HORAGE, TMPGKB->GM8_CODCRM, TMPGKB->RA_NOME,;
	TMPGKB->GM8_CODSAL, TMPGKB->GF3_DESCRI      , TMPGKB->GM8_CODREC, TMPGKB->GNZ_DESREC, .F.})
	TMPGKB->(DbSkip())
EndDo

Aadd(aHDados, {" "          , "cStatus" , "@BMP"  , 2                      , 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Data Agenda", "dDatAge" , "@D"    , Len(TMPGKB->GM8_DATAGE), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Hora Agenda", "cHorAge" , "@99:99", Len(TMPGKB->GM8_HORAGE), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

Aadd(aHDados, {"Profissional", "cMedico", "@!"    , Len(TMPGKB->GM8_CODCRM), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Nome"        , "cNome"  , "@!"    , Len(TMPGKB->RA_NOME)   , 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

Aadd(aHDados, {"Sala"       , "cSala"   , "@!"    , Len(TMPGKB->GM8_CODSAL), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Descrição"  , "cDesSal" , "@!"    , Len(TMPGKB->GF3_DESCRI), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Recurso"    , "cRecurso", "@!"    , Len(TMPGKB->GM8_CODREC), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {"Descrição"  , "cDesRec" , "@!"    , Len(TMPGKB->GNZ_DESREC), 0, ".F.", "", "C", "", "V" ,"" , "","","V"})

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Agendamentos") From aSize[5]/5, aSize[6]/100 To aSize[6], aSize[5]*0.65	PIXEL Of oMainWnd

oGDDados := MsNewGetDados():New(0, 0, 200, 200, 0,,,,,,,,,, oDlg, aHDados, aCDados)
oGDDados:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {|| oDlg:End()},, aButtons)

DbSelectArea("TMPGKB")
DbCloseArea()

RestArea(aArea)
return(nil)

Function HS_M13VLD()
Local cCodApac := GetMv("MV_PSUSPAC")

Local lRet := .T.
Local aNomMed := {{"GKB_CRMSOL","GKB_NOMMED"},{"GKB_CRMEXC", "GKB_MEDEXC"},{"GKB_CRMRES", "GKB_MEDRES"},{"GKB_CRMAUT", "GKB_MEDRES"}}
Local aVldApac := {}
Local cMsgErro := ""

If ReadVar() == "M->GKB_TPLAUD"
	cTab := &(ReadVar())
	If(!Empty(cTab) .And. cTab <> "0" .And. Len(oEnGK8:oBox:aDialogs) >= val(cTab))
		//Fs_SetFold(cTab)
		oEnGK8:SetFocus(val(cTab))//:oBox:aDialogs[val(cTab)]:SetFocus()
		oEnGK8:OBOX:NOPTION := val(cTab)
		oEnGK8:Refresh()//:oBox:aDialogs[val(cTab)]:Refresh()
	Endif
ElseIf ReadVar() == "M->GKB_REGGER"
	DbSelectArea("GD4")
	DbSetOrder(2)
	
	If !(lRet := HS_SeekRet("GBH", ReadVar(), 1, .F., "GKB_NOMPAC", "GBH_NOME",,, .T.))
		Hs_MsgInf("Prontuário não encontrado","Atenção", "Validação Solicitação")
	ElseIf !(lRet := DBSeek(xFilial("GD4") + M->GKB_REGGER +"1") .And. !(GD4->GD4_CODPLA $ cCodApac) .And. !Empty( GD4->GD4_CODPLA))
		IF !(DBSeek(xFilial("GD4") + M->GKB_REGGER +"1"))
			Hs_MsgInf("Paciente nao possui plano atribuido","Atenção", "Validação Solicitação")
		Else
			Hs_MsgInf("Paciente possui plano APAC devera ser atendido pela Solicitacao APAC","Atenção", "Validação Solicitação")
		EndIf
	Else
		__cProntu := &(ReadVar())
	EndIf
	
ElseIf ReadVar() == "M->GKB_CODPRO"
	If !(lRet := HS_SeekRet("GA7", ReadVar(), 1, .F., "GKB_DESPRO", "GA7_DESC",,, .T.) )
		Hs_MsgInf("Procedimento não encontrado","Atenção", "Validação Solicitação")
	Else
		cCodProSus := &(ReadVar())
	EndIf
	
ElseIf ReadVar() == "M->GKB_REGATE"
	If !(lRet := HS_SeekRet("GCY", ReadVar(), 1, .F., "GKB_CRMSOL", "GCY_CODCRM",,, .T.) .And. HS_SeekRet("SRA", "M->GKB_CRMSOL", 11, .F., "GKB_NOMMED", "RA_NOME",,, .T.) )
		Hs_MsgInf("Atendimento não encontrado","Atenção", "Validação Solicitação")
	EndIf
	
ElseIf ReadVar() == "M->GKB_CODMOT"
	If !(lRet := HS_SeekRet("GK9", ReadVar(), 1, .F., "GKB_DESMOT", "GK9_DESMOT",,, .T.) )
		Hs_MsgInf("Motivo não encontrado","Atenção", "Validação Solicitação")
	EndIf
ElseIf ReadVar() == "M->GKB_DTINVL"
	If GetMv("MV_VLDGUIA",,0) > 0
		M->GKB_DTFIVL := &(ReadVar())+GetMv("MV_VLDGUIA",,0)
	EndIf
ElseIf ReadVar() == "M->GKB_DTFIVL"
	if !(lRet := M->GKB_DTFIVL > M->GKB_DTINVL)
		Hs_MsgInf("Data final da validade não pode ser superior à Inicial","Atenção", "Validação Solicitação de APAC")
	endIf
ElseIf ReadVar() $ "M->GKB_CRMSOL/M->GKB_CRMEXC/M->GKB_CRMRES/M->GKB_CRMAUT"
	If !(lRet := HS_SeekRet("SRA", ReadVar(), 11, .F., aNomMed[ aScan(aNomMed,{|aVet|  "M->"+aVet[1] == ReadVar() }), 2], "RA_NOME",,, .T.) )
		Hs_MsgInf("Profissional não encontrado","Atenção", "Validação Solicitação")
	EndIf
ElseIf ReadVar() == "M->GKA_CODPRO"
	If !Empty( Select( "GKB" ) )
		If !(lRet := HS_SeekRet("GA7", ReadVar(), 1, .F., "oGKA:aCols[oGKA:nAt, nGKADesPro]", "GA7_DESC",,, .T.) )
			Hs_MsgInf("Procedimento não encontrado","Atenção", "Validação Solicitação")
		EndIf
	EndIf
Endif

Return(lRet)

Function HS_M13TPL()
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

HS_BDados("GFS" , @aHGFS , @aCGFS , @nUGFS , 1   ,        , " GFS.GFS_TPQUES = '3' AND GFS.GFS_IDATIV = '1' ",        ,        ,"/"      ,         ,        ,        ,        ,        ,.T.     ,     ,        ,         ,           ,         ,{"GFS_CDQUES","GFS_DSQUES"},      ,          ,         ,         ,         ,           )
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
		
Function HS_M13LEG()
Local aLegenda := {	{"BR_VERDE"   , OemToAnsi("Solicitada")}, ; 
                    {"BR_AMARELO" , OemToAnsi("Aguardando Autorização")}, ; 
                    {"BR_AZUL"    , OemToAnsi("Autorizada")}, ; 
                    {"BR_LARANJA" , OemToAnsi("Agendada")}, ; 
                    {"BR_VERMELHO", OemToAnsi("Devolvida")}, ;  
                    {"BR_CINZA"   , OemToAnsi("Cancelada")}}                 
//Se UPDGH110 foi executado (permitir agendamento multiplo) adiciona status "6"
if SuperGetMv("MV_AGDMSES",nil,.F.)
	aAdd(aLegenda,{"BR_MARRON" , OemToAnsi("Agendado / Agend. Permitido")})
endif
		
BrwLegenda("Solicitação APAC","Legenda", aLegenda) 
Return(nil)
	
Static Function FS_FilM13(lSetFilter)
Local lRet     := .F.
Local oObjMBrw := GetObjBrow()
Local dDatIni := CtoD(""), dDatFim := CtoD(""), cStatus := ""

If (lRet := Pergunte("HSPM13"))
	dDatIni := MV_PAR01
	dDatFim := MV_PAR02
	cStatus := AllTrim(MV_PAR03)
	
	cFilM13 := "     GKB_FILIAL = '" + xFilial("GKB") + "' AND GKB_DATSOC BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "'"
	cFilM13 += " AND GKB_STATUS IN (" + HS_InSql(cStatus) + ") "
	If lSetFilter
		MsgRun("Selecionando as Solicitações ...", "Aguarde ...", {|| SetMBTopFilter("GKB", cFilM13), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando os Agendamentos..."###"Aguarde..."
	EndIf
EndIf

DbSelectArea("GKB")

Return(lRet)

Function Hs_FilCBxT(cCampo, cTitulo)
Local aArea   := getArea()

Local aHDados := {}
Local aCDados := {}
Local nCont   := 0
Local nOpca   := 0
Local nPos    := 0
Local cRet    := ""
Local cEsp    := ""

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

//Verificando o tamanho de GKB_STATUS em SX1
DbSelectArea("SX1")
DbSetOrder(1)                 
If DbSeek("HSPM13    03") .and. "Status" $ X1Pergunt() //Status
	cEsp := Repl(" " , SX1->X1_TAMANHO - len(cRet)      )
EndIf  

__RetStatus := cRet + cEsp
RestArea(aArea)
Return(.T.)

Function HS_RetCBxT()
&(Readvar()) := __RetStatus
Return(.T.)

*/

Static Function Fs_DbCStat(oObj, nPos)

Default nPos := 1

If oObj:aCols[oObj:nAt, nPos] == "LBTIK"
	oObj:aCols[oObj:nAt, nPos] := "LBNO"
Else
	oObj:aCols[oObj:nAt, nPos] := "LBTIK"
EndIf
Return(nil)


//Controle de Sessões
Function Hs_CtrSesT(cAlias, nReg, nOpc)
Local cSql := ""
Local nHd	:= 0
Local cGKBSolici := ""
Local aHGm8 := {}, aCGm8 := {}, nUGm8 := 0
Local cCadastro := "Controle Sessões"
Local aCpos     := {}
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

Private oEnGKB, oGDGm8
Private aTela   := {}, aGets := {}
Private aPGets := {}
Private nOpcDlg := 0
Private aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Private nOpcE   := GD_UPDATE

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

If !Hs_ExisDic({{"C","GKB_SEQAGE","FNC 148152"}})
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
DbSeek("GKB")
While SX3->(!Eof()) .And. X3_ARQUIVO == "GKB"
	If X3Uso(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. (!SX3->X3_CAMPO $ "GKB_CODMOT/GKB_DESMOT")
		Aadd(aCpos, SX3->X3_CAMPO)
	EndIf
	DbSkip()
EndDo

cSql := " SELECT GKB.R_E_C_N_O_ GKB_RECNO, GM8.R_E_C_N_O_ GM8_RECNO"
cSql += "   FROM "+RetSqlName("GKB")+" GKB  "
cSql += "			JOIN "+RetSqlName("GM8")+" GM8 ON GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' AND GM8_CODAGE = GM8_AGDPRC "
cSql += "			 AND GKB_SEQAGE = GM8_CODAGE  AND GM8_REGATE = '"+GCY->GCY_REGATE+"' "
cSql += "  WHERE GKB.GKB_FILIAL = '"+xFilial("GKB")+"' AND GKB.D_E_L_E_T_ <> '*' "

TCQUERY cSQL NEW ALIAS "QRYM13"

If QRYM13->(EoF())
	Hs_MsgInf("Não há sessões pendentes para esse atendimento.","Atenção","Controle Sessões")
	DbSelectArea("QRYM13")
	DbCloseArea()
	Return(Nil)
EndIf

DbSelectArea("GKB")
DbSetOrder(1)
DbGoTo(QRYM13->GKB_RECNO)

RegToMemory("GKB", .F.)

cGKBSolici := GKB->GKB_SOLICI


DbSelectArea("GM8")
DbSetOrder(1)
DbGoTo(QRYM13->GM8_RECNO)

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

oEnGKB := MsMGet():New("GKB" ,QRYM13->GKB_RECNO ,nOpc,,,, aCpos  , {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,,oDlg,,.F.)
oEnGKB:oBox:align := CONTROL_ALIGN_TOP

oGDGm8 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],nOpcE,"AllwaysTrue()","AllwaysTrue()","",,,,,,,oDlg,aHGM8,aCGM8)
oGDGm8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGDGm8:oBrowse:blDblClick:= {||  IIF( oGDGm8:aCols[oGDGm8:nAt, nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .AND. oGDGm8:oBrowse:ColPos <> nGm8OriCan .AND. oGDGm8:oBrowse:ColPos <> nGm8Motivo, Fs_DbCStat(oGDGm8, nGm8IdMarc), IIF( oGDGm8:aCols[oGDGm8:nAt, nGm8Status] $ "BR_PINK",Nil,oGDGm8:EDITCELL( oGDGm8:OBROWSE, oGDGm8:oBrowse:nAt, oGDGm8:oBrowse:nColPos )))} //Marca o Agendamento pela Ocupacao

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIF(Fs_VldCtrl(),nOpcDlg := 1,nOpcDlg := 0), oDlg:End() }, ;
{|| nOpcDlg := 0, oDlg:End() },, aButtons)

If nOpcDlg == 1 .And. aScan(oGDGm8:aCols, {|aVet| aVet[nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. (aVet[nGm8IdMarc] == "LBTIK" .OR. !Empty(aVet[nGm8Motivo]))}) # 0
	Begin Transaction
	Fs_GrvCtrl()
	End Transaction
EndIF

DbSelectArea("QRYM13")
DbCloseArea()

RestArea(aArea)
MBrChgLoop(.F.)
Return(nil)

Static Function Fs_VldCtrl()
Local lRet := .F.


If aScan(oGDGm8:aCols, {|aVet| aVet[nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. aVet[nGm8IdMarc] == "LBTIK"}) == 0
	return(.T.)
EndIf

If !(lRet := dDataBase < GKB->GKB_DTFIVL)
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
	
	If !Empty(GKB->GKB_NRAUT)
		RecLock("GCZ",.F.)
		GCZ->GCZ_NRGUIA := GKB->GKB_NRAUT
		MsUnLock()
	EndIf
	
	For nCont := 1 To Len(oGDGm8:aCols)
		If oGDGm8:aCols[nCont, nGm8Status] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. oGDGm8:aCols[nCont, nGm8IdMarc] == "LBTIK" ;
			.AND. Empty(oGDGm8:aCols[nCont, nGm8OriCan]) .AND. Empty(oGDGm8:aCols[nCont, nGm8Motivo])
			
			aProced := Hs_RtPrAgd(oGDGm8:aCols[nCont, nGm8CodAge], oGDGm8:aCols[nCont, nGm8CodPro])
			
			For nContPro := 1 to len(aProced)
				cSeqDes := GetSxENum("GD7","GD7_SEQDES",,1)
				ConfirmSx8()
				
				aRValDes := HS_RValPr(aProced[nContPro], GCZ->GCZ_CODPLA, oGDGm8:aCols[nCont, nGm8CodLoc],;
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

Function Hs_RLayTer(cCodSol, cNrSeqG)
Local cRet    := ""
Local aArea   := getArea()
Local aResp   := {}//HS_BusResp("GK8", {{"GK8->GK8_SOLICI", cCodSol}}, "PER")
Local aVet    := {}
Local nI      := 0

Default cNrSeqG := ""

If !Empty(cCodSol)
	
	DbSelectArea("GKB")
	DbSetOrder(1) //GKB_FILIAL+GKB_SOLICI
	DbSeek(xFilial("GKB")+cCodSol)
	
	aResp := HS_BusResp("GK8", {{"GK8->GK8_SOLICI", cCodSol}},"")
	
	aVet := Fs_RLayApc(Hs_IniPadr("GFS",1,GKB->GKB_CDQUES,"GFS_TIPSUS",,.F.), cNrSeqG)
	
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

//Retorno da solicitação de Sessoes
Function Hs_SolAgen(cCodAge, cCpoRet, aCposRet)
Local cRet  := ""
Local aArea := getArea()
Local cSql  := ""

cSql := " SELECT GKB.R_E_C_N_O_ " //GKB.GKB_NRAUT "
cSql += "   FROM "+RetSqlName("GKB")+" GKB  "
cSql += "	JOIN "+RetSqlName("GM8")+" GM8 ON GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' AND GM8_CODAGE = GM8_AGDPRC "
cSql += "		 AND GKB_SEQAGE = GM8_SEQAGE  AND GM8_CODAGE = '"+cCodAge+"' "
cSql += "  WHERE GKB.GKB_FILIAL = '"+xFilial("GKB")+"' AND GKB.D_E_L_E_T_ <> '*' "

TCQUERY cSQL NEW ALIAS "QRYGKB"

If QRYGKB->(!Eof())
	DbSelectArea("GKB")
	DbSetOrder(1)
	DbGoTo(QRYGKB->R_E_C_N_O_)
	
	cRet := &("GKB->"+cCpoRet)
	
	If !Empty(aCposRet)
		HS_DefVar("GKB", 1, GKB->GKB_SOLICI, aCposRet)
	Endif
EndIf

QRYGKB->(DbCloseArea())

RestArea(aArea)
Return(cRet)

Static Function Fs_RLayApc(cTipLay, cNrSeqG)
Local aRet     := {}
Local cNrGuia  := ""
Local nQtdGuia := 0

If cTipLay == "Q"
	aRet := {	{"'Q'",1},;    //APA_IDENT
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
	aRet := {	{"'R'",1},;     //APA_IDENT
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
	
	
	aRet := {	{"'N'",1},;                                  //APA_IDENT
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
	aRet := {	{"'B'",1},;     //APA_IDENT
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
			GM8->GM8_STATUS := "2"           //Bloqueado
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


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSXB ºAutor  ³Microsiga           º Data ³  09/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para compatibilizar as consultas padroes      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSXB()
Local aArea := GetArea()

dbSelectArea("SXB")
dbSetOrder(1)

If DbSeek("GBJ        ")
	RecLock("SXB", .F.)
		DbDelete()
	MsUnLock()
EndIf

If DbSeek("GBJ   101DB")
	RecLock("SXB", .F.)
		XB_DESCRI := "Profissionais"
		XB_CONTEM := "GBJ"
	MsUnLock()
EndIf

If DbSeek("GBJ   20101")
	RecLock("SXB", .F.)
		XB_DESCRI := "Cod do Profissional"
	MsUnLock()
EndIf

If DbSeek("GBJ   40101")
	RecLock("SXB", .F.)
		XB_DESCRI := "Cod do Profissional"
		XB_CONTEM := "GBJ_CRM"
	MsUnLock()
EndIf

If DbSeek("GBJ   40102")
	RecLock("SXB", .F.)
		XB_DESCRI := "Nome do Profissional"
		XB_CONTEM := "Posicione('SRA',11,xfilial('SRA')+GBJ->GBJ_CRM,'RA_NOME')"
	MsUnLock()
EndIf

If DbSeek("GBJ   501  ")
	RecLock("SXB", .F.)
		XB_CONTEM := "GBJ->GBJ_CRM"
	MsUnLock()
EndIf

If DbSeek("GBJ   502  ")
	RecLock("SXB", .F.)
		XB_CONTEM := "Posicione('SRA',11,xfilial('SRA')+GBJ->GBJ_CRM,'RA_NOME')"
	MsUnLock()
EndIf

If DbSeek("GBJ   601  ")
	RecLock("SXB", .F.)
		XB_CONTEM := "#HS_FGBJ()"
	MsUnLock()
EndIf

RestArea(aArea)
Return
