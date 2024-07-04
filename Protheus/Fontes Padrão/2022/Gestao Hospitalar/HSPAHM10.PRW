#INCLUDE "hspahm10.ch"
#INCLUDE "PROTHEUS.CH" 
#include "TopConn.ch"
#INCLUDE "VKEY.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ HSPAHM10 ณ Autor ณ Mario Arizono         ณ Data ณ23/04/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Complemento da prescricao                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHM10(cAtendimento, cCodLoc, cReserv, cNomPac, cQuarto, cLeito)
Local aSvKeys		:= GetKeys()
Local bKeyF4		:=	SetKey(VK_F4, {|| FS_M10Leg() })
Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPEnc := {}
Local aButtons := {}, aJoin := {}
Local nOpcA    := 0
Local nRadPes := 0, oRadPes
Local oVisual, nPosicao := 0
Local oCarater, nPosCarac := 0

Private cRegAten  := cAtendimento
Private lNovoPed := .F.
Private lAlterou := .F.
Private cPaciente := ""
Private cObserv  := Space(330), dDatExe := CTOD("  /  /  "), cHorExe := SPACE(5), cMemObs := ""
Private oObsRea, oDatExe, oHorExe, oMemObs
Private cObsDie := Space(330), dDatDie := CTOD("  /  /  "), cHorDie := SPACE(5), cMemDie := ""
Private oObsDie, oDatDie, oHorDie, oMemDie

private oMedSol, cMedSol := Space(TamSx3("GBY_CODCRM")[1])
private oQtde, nQtde := Criavar("GGD_QTDILU")

Private oChkAsso, lChkAsso := .T.
Private oChkAvul, lChkAvul := .F.

Private oChkItem,   lChkItem := .T.
Private oChkProPAD, lChkProPad := .F.

Private aTela := {}, aGets := {}, aColGhx := {}, aHorMarc := {}
Private nRadEfe, nRadUrg , oRadEfe, oRadUrg
Private nRadIte, nRadPro , oRadIte, oRadPro
Private nAtAnt := 1 , nGhv := 0

Private aHGHV := {}, aCGHV := {}, nUGHV := 0, oGDGHV
Private aHGHX := {}, aCGHX := {}, nUGHX := 0, oGDGHX
Private aHGBI := {}, aCGBI := {}, nUGBI := 0, oGDGBI
Private aHGNT := {}, aCGNT := {}, nUGNT := 0, oGDGNT
Private aHGNP := {}, aCGNP := {}, nUGNP := 0, oGDGNP
Private aHCuid := {}, aCCuid := {}, nUCuid := 0, oCuid
Private oCPres
Private aHDiet := {}, aCDiet := {}, nUDiet := 0, oDiet
Private oCDPres

Private aLeg    := {	{"GHV_STATUS == '0'","BR_VERMELHO"},{"GHV_STATUS == '1'","BR_VERDE"},;
						{"GHV_STATUS == '2'","BR_AZUL"},{"GHV_STATUS == '3' .And. GHV_DATPRE >= dDataBase","BR_CINZA"},;
						{"GHV_STATUS == '3' .And. GHV_DATPRE < dDataBase","BR_PINK"}}
						
Private aLegIte := {	{"GHX_STAENF == '0'","BR_VERDE"}   , {"GHX_STAENF == '1'","BR_AMARELO"},;
						{"GHX_STAENF == '2'","BR_VERMELHO"}, {"GHX_STAENF == '3'","BR_PRETO"},;
						{"GHX_STAENF == '4'","BR_MARROM"}}

Private aLegGNR := {	{"GNR_STATUS == '0'","BR_VERDE"},    {"GNR_STATUS == '1'","BR_AMARELO"},;
						{"GNR_STATUS == '2'","BR_VERMELHO"}, {"GNR_STATUS == '3'","BR_PRETO"}}

Default cReserv := ""

If !HS_EXISDIC({{"T", "GNR"}, {"T", "GNT"}})
	Return()
Endif

If !LockByName("ExecM24" + cAtendimento,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",cAtendimento,.T.) 
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",cAtendimento)   
EndIf

nQtde := 1

aSize 			:= MsAdvSize(.T.)

aObjects := {}
aAdd( aObjects, { 100, 100, .T., .T., .T.} )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aFoldPri := MsObjSize( aInfo, aObjects, .T. )

// medicamentos
aObjects := {}
aAdd( aObjects, { 100, 003, .T., .T.} )
aAdd( aObjects, { 100, 042, .T., .T., .T.} )
aAdd( aObjects, { 100, 055, .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T. )

//Cuidados m้dicos
aObjects := {}
aAdd( aObjects, { 100, 030, .T., .T.} )
aAdd( aObjects, { 100, 020, .T., .T., .T.} )
aAdd( aObjects, { 100, 050, .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPCuid := MsObjSize( aInfo, aObjects, .T.)

//prescricao enfermagem

aObjects := {}
aAdd( aObjects, { 100, 003, .T., .T.} )
aAdd( aObjects, { 100, 042, .T., .T., .T.} )
aAdd( aObjects, { 100, 055, .T., .T.,.T.} )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPreEnf := MsObjSize( aInfo, aObjects, .T. )


aObjects := {}
aAdd( aObjects, { 060, 100, .T.,.T.} )
aAdd( aObjects, { 040, 100, .T.,.T.,.T.} )


//Medicamentos
aInfo  := { aPPanel[3, 2], aPPanel[3, 1], aPPanel[3, 4], aPPanel[3, 3], 0, 0 }
aPInfo := MsObjSize( aInfo, aObjects, .T., .T.)

//Cuidados Medicos
aInfo    := { aPCuid[3, 2], aPCuid[3, 1], aPCuid[3, 4], aPCuid[3, 3], 0, 0 }
aPInfCui := MsObjSize( aInfo, aObjects, .T., .T.)



aObjects := {}
aAdd( aObjects, { 100, 040, .T.,.T.,.T.} )
aAdd( aObjects, { 100, 030, .T.,.T.,.T.} )
aAdd( aObjects, { 100, 030, .T.,.T.,.T.} )

//Medicamentos
aInfo := { aPInfo[2, 2], aPInfo[2, 1], aPInfo[2, 4], aPInfo[2, 3], 0, 0 }
aPPed := MsObjSize( aInfo, aObjects, .T.)


//Medicamentos
aObjects := {}
aAdd( aObjects, { 100, 030, .T.,.T.,.T.} )
aAdd( aObjects, { 100, 005, .T.,.T.,.T.} )
aAdd( aObjects, { 100, 010, .T.,.T.,.T.} )

aInfo := { aPInfo[1, 2], aPInfo[1, 1], aPInfo[1, 4], aPInfo[1, 3], 0, 0 }
aPPro := MsObjSize( aInfo, aObjects, .T.)


//Cuidados M้dicos
aObjects := {}
aAdd( aObjects, { 100, 100, .T.,.T.,.T.} )

aInfo := { aPInfCui[1, 2], aPInfCui[1, 1], aPInfCui[1, 4], aPInfCui[1, 3], 0, 0 }
aPPre := MsObjSize( aInfo, aObjects, .T., .T.)


aJoin := {{" JOIN " + RetSqlName("SRA") + " SRA", "SRA.RA_NOME", "SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GHV.GHV_CODCRM", "GHV_NOMMED"}}
aJoin := {{" LEFT JOIN " + RetSqlName("GHS") + " GHS", "GHS.GHS_DESMOT", "GHS.GHS_FILIAL = '" + xFilial("GHS") + "' AND GHS.D_E_L_E_T_ <> '*' AND GHS.GHS_MOTIVO = GHV.GHV_MOTIVO", "GHV_DESMOT"}}

nGhv := HS_BDados("GHV", @aHGHV, @aCGHV, @nUGHV, 1,, "GHV->GHV_REGATE = '"+ cAtendimento +"' AND GHV->GHV_RESERV = '"+ cReserv +"'",,"GHV_STATUS","GHV_SEQPRE/GHV_DATPRE/GHV_HORCRI/GHV_NOMMED/GHV_DESMOT",,,,,,.T.,aLeg,,,,,,aJoin)
nGhvStatus := aScan(aHGHV, {|aVet| aVet[2] == "GHV_STATUS"})
nGhvSeqPre := aScan(aHGHV, {|aVet| aVet[2] == "GHV_SEQPRE"})
nGhvDatPre := aScan(aHGHV, {|aVet| aVet[2] == "GHV_DATPRE"})
nGhvHorCri := aScan(aHGHV, {|aVet| aVet[2] == "GHV_HORCRI"})

If nGhv == 0
	HS_MsgInf(STR0001, STR0002, STR0003) //"Nใo existe prescri็ใo para este paciente."###"Aten็ใo"###"Valida็ใo Prescri็ใo."
	UnLockByName("ExecM24" + cAtendimento,.T.,.T.,.F.) 
	HSPDelFiCo("ExecM24",cAtendimento) 
	Return(Nil)
Endif


FS_MntMed(cAtendimento, aCGHV[1, nGhvSeqPre], cCodLoc, .T.)
nGhxSolici := aScan(aHGHX, {|aVet| aVet[2] == "GHX_SOLICI"})
nGhxStaEnf := aScan(aHGHX, {|aVet| aVet[2] == "GHX_STAENF"})
aHGHX[nGhxStaEnf, 1] := ""
aHGHX[nGhxStaEnf, 3] := "@BMP"
nGhxTpItmp := aScan(aHGHX, {|aVet| aVet[2] == "GHX_TPITMP"})
aHGHX[nGhxTpItmp, 11] := STR0004+ CHR(187) + STR0005+ CHR(187) + STR0006+ CHR(187) + STR0007 //"1=Medicamento;2=Dieta;3=Cuidado;4="###" Med. Composto;5="###" Kit;6="###" Associado;7=Material "
nGhxCodPro := aScan(aHGHX, {|aVet| aVet[2] == "GBI_PRODUT"})
aHGHX[nGhxCodPro, 1] := STR0008 //"Principal"
nGhxCodPri := aScan(aHGHX, {|aVet| aVet[2] == "GHX_CDMEDI"})
aHGHX[nGhxCodPri, 1] := STR0009       //"Codigo"
nGhxDesPro := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DSITEM"})
nGhxDunico := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DUNICO"})
aHGHX[nGhxDunico, 1] := STR0010 //"Unid. Estoque"
nGhxDesmot := aScan(aHGHX, {|aVet| aVet[2] == "GHX_DESMOT"})
aHGHX[nGhxDesmot, 1] := STR0011 //"Motiv. Suspensใo"
nGhxArmSet := aScan(aHGHX, {|aVet| aVet[2] == "GCS_ARMSET"})
aHGHX[nGhxArmSet, 1] := STR0012 //"Armaz. Origem"
nGhxQtde  := aScan(aHGHX, {|aVet| aVet[2] == "GHX_QTDMED"})
nGhxItemBr:= aScan(aHGHX, {|aVet| aVet[2] == "GHX_ITEMBR"})
nGhxAprese:= aScan(aHGHX, {|aVet| aVet[2] == "GHX_APRESE"})

aJoin := {{" JOIN " + RetSqlName("SB1") + " SB1", "SB1.B1_DESC", "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GBI.GBI_PRODUT", "GBI_DESC  "}}
HS_BDados("GBI", @aHGBI, @aCGBI, @nUGBI, 1,, "(GBI_TIPO IN ('0', '1', '3') AND GBI_ENFERM = '1') ",,,"GBI_PRODUT/GBI_DESC  /GBI_TIPO  ",,,,,, .T.,,,,,,,aJoin)
nGbiProdut := aScan(aHGBI, {|aVet| aVet[2] == "GBI_PRODUT"})
nGbiDescri := aScan(aHGBI, {|aVet| aVet[2] == "GBI_DESC  "})

FS_CuiMed(cAtendimento, aCGHV[1, nGhvSeqPre], .T.)
nCuidProdu := aScan(aHCuid, {|aVet| aVet[2] == "GHX_CDMEDI"})
nCuidDesPr := aScan(aHCuid, {|aVet| aVet[2] == "GHX_DSITEM"})
nCuidItem  := aScan(aHCuid, {|aVet| aVet[2] == "GHX_ITEMBR"})


aJoin := {{" JOIN " + RetSqlName("GNP") + " GNP", "GNP.GNP_DESCUI", "GNP.GNP_FILIAL = '" + xFilial("GNP") + "' AND GNP.D_E_L_E_T_ <> '*' AND GNP.GNP_CODCUI = GNT.GNT_CODCUI", "GNT_DESCUI"}}
HS_BDados("GNT", @aHGNT, @aCGNT, @nUGNT, 1,, "GNT.GNT_REGATE = '" + cAtendimento + "' ",.T.,,,,,,,,,,,,,,,aJoin)

nGntStareg := aScan(aHGNT, {|aVet| aVet[2] == "HSP_STAREG"})
nGntSeqIte := aScan(aHGNT, {|aVet| aVet[2] == "GNT_SEQITE"})
nGntCodCui := aScan(aHGNT, {|aVet| aVet[2] == "GNT_CODCUI"})
nGntDesCui := aScan(aHGNT, {|aVet| aVet[2] == "GNT_DESCUI"})
nGntDatLan := aScan(aHGNT, {|aVet| aVet[2] == "GNT_DATLAN"})
nGntHorLan := aScan(aHGNT, {|aVet| aVet[2] == "GNT_HORLAN"})
nGntDatIni := aScan(aHGNT, {|aVet| aVet[2] == "GNT_DATINI"})
nGntHorIni := aScan(aHGNT, {|aVet| aVet[2] == "GNT_HORINI"})
nGntDatFim := aScan(aHGNT, {|aVet| aVet[2] == "GNT_DATFIM"})
nGntHorFim := aScan(aHGNT, {|aVet| aVet[2] == "GNT_HORFIM"})
nGntQtdade := aScan(aHGNT, {|aVet| aVet[2] == "GNT_QTDADE"})
nGntUsuari := aScan(aHGNT, {|aVet| aVet[2] == "GNT_USUARI"})
nGntSituac := aScan(aHGNT, {|aVet| aVet[2] == "GNT_SITUAC"})

If Empty(aCGNT[1, nGntSeqIte])
	aCGNT[1, nGntSeqIte] := Soma1(aCGNT[1, nGntSeqIte], Len(aCGNT[1, nGntSeqIte]))
EndIf


HS_BDados("GNP", @aHGNP, @aCGNP, @nUGNP, 1,, "GNP.GNP_TPCUID = '1' AND GNP.GNP_IDEATI = '1' ",,,"GNP_CODCUI/GNP_DESCUI/GNP_CONTRO",,,,,, .T.)
nGnpCodCui := aScan(aHGNP, {|aVet| aVet[2] == "GNP_CODCUI"})
nGnpDesCui := aScan(aHGNP, {|aVet| aVet[2] == "GNP_DESCUI"})
nGnpContro := aScan(aHGNP, {|aVet| aVet[2] == "GNP_CONTRO"})

If Empty(aCGNP[1, nGnpDesCui])
	aCGNP[1, nGnpCodCui] := ""
	aCGNP[1, nGnpContro] := ""
Endif

FS_Dietas(cAtendimento, aCGHV[1, nGhvSeqPre], .T.)
nDieProdut := aScan(aHDiet, {|aVet| aVet[2] == "GHX_CDMEDI"})
nDieDesPro := aScan(aHDiet, {|aVet| aVet[2] == "GHX_DSITEM"})
nDieItemBr := aScan(aHDiet, {|aVet| aVet[2] == "GHX_ITEMBR"})
nDieVolume := aScan(aHDiet, {|aVet| aVet[2] == "GHX_VOLUME"})
nDieCdfrqa := aScan(aHDiet, {|aVet| aVet[2] == "GHX_CDFRQA"})
nDieDsfrqa := aScan(aHDiet, {|aVet| aVet[2] == "GHX_DSFRQA"})
nDieCodVia := aScan(aHDiet, {|aVet| aVet[2] == "GHX_CODVIA"})
nDieDesVia := aScan(aHDiet, {|aVet| aVet[2] == "GHX_DESVIA"})
nDieVelInf := aScan(aHDiet, {|aVet| aVet[2] == "GHX_VELINF"})
nDieCdMinf := aScan(aHDiet, {|aVet| aVet[2] == "GHX_CDMINF"})
nDieDsMinf := aScan(aHDiet, {|aVet| aVet[2] == "GHX_DSMINF"})
nDieObsReg := aScan(aHDiet, {|aVet| aVet[2] == "GHX_OBSREG"})

nOpcA := 0

DEFINE MSDIALOG oDlgM10 TITLE STR0013 + ALLTRIM(cNomPac) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel    //"Complemento da Prescri็ใo - "

@ aFoldPri[1, 1], aFoldPri[1, 2] FOLDER oFoldPri SIZE aFoldPri[1, 3], aFoldPri[1, 4] Pixel Of oDlgM10 Prompts STR0119, STR0123, STR0124 //"Mat/Med", "Dietas", "Cuidados"
oFoldPri:Align := CONTROL_ALIGN_ALLCLIENT

oPPesq	:=	tPanel():New(aPPanel[1, 1], aPPanel[1, 2],, oFoldPri:aDialogs[1],,,,,, aPPanel[1, 3], aPPanel[1, 4])
oPPesq:Align := CONTROL_ALIGN_ALLCLIENT


oBtnLeg  := tButton():New(002, aPPanel[1, 4] - 260, STR0014, oPPesq, {|| FS_LegIte() }, 050, 015,,,, .T.)  //"Leg. Itens Presc."
oBtnHor  := tButton():New(002, aPPanel[1, 4] - 200, STR0015, oPPesq, {|| FS_MntHor(cNomPac, cCodLoc, cAtendimento, oGDGHV:aCols[oGDGHV:oBrowse:nAt, nGhvSeqPre], oGdGHX:aCols)}, 050, 015,,,, .T.) //"Horarios"
oBtnEnv  := tButton():New(002, aPPanel[1, 4] - 140, STR0016, oPPesq, {|| FS_GrvSol(cAtendimento, cCodLoc, cReserv, cNomPac, cQuarto, cLeito, oGDGHV:aCols[oGDGHV:oBrowse:nAt, nGhvSeqPre])}, 055, 015,,,, .T.) //"Enviar Presc. Farm."
oBtnExit := tButton():New(002, aPPanel[1, 4] - 075, STR0017, oPPesq, {||FS_GRVGHX(cAtendimento), oDlgM10:end()}, 050, 015,,,, .T.) //"Sair"

@ aPPanel[2, 1]+6, aPPanel[2, 2] FOLDER oFolder SIZE aPPanel[2, 3], aPPanel[2, 4]-6 Pixel Of oFoldPri:aDialogs[1] Prompts STR0018 //"Medicamentos"

oGDGHX  := MsNewGetDados():New(aPPanel[2, 1], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], GD_DELETE,,,,,, 99999,,,, oFolder:aDialogs[1], aHGHX, aCGHX)
oGDGHX:oBrowse:bDelete    := {|| IIf(FS_VldDel(oGDGHX:aCols[oGDGHX:oBrowse:nAt, nGhxStaEnf], oGDGHX:aCols[oGDGHX:oBrowse:nAt, nGhxItemBr]), {HS_GDAtrib(oGDGHX, {{nGhxStaEnf, "BR_CINZA", "BR_VERDE"}}), oGDGHX:DELLINE()}, .F.)}
oGDGHX:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT

HS_GDPesqu( , , oGDGhx, oPPesq, 002,.T., 5)

oPGDGBI	:=	tPanel():New(aPPro[1, 1], aPPro[1, 2],, oFoldPri:aDialogs[1],,,,,, aPPro[1, 3], aPPro[1, 4])

@ aPPro[1, 1], aPPro[1, 2] FOLDER oFolderPro SIZE aPPro[1, 3], aPPro[1, 4] Pixel Of oPGDGBI Prompts STR0019    //"Materiais/Medicamentos/Kits"
oFolderPro:Align := CONTROL_ALIGN_ALLCLIENT

oGDGBI := MsNewGetDados():New(aPPro[1, 1], aPPro[1, 2], aPPro[1, 3], aPPro[1, 4],,,,,,,,,,, oFolderPro:aDialogs[1], aHGBI, aCGBI)
oGDGBI:oBrowse:BlDblClick := {|| FS_IncMed(cCodLoc) }
oGDGBI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oPFLancam	:=	tPanel():New(aPPro[2, 1], aPPro[2, 2],, oFoldPri:aDialogs[1],,,,,, aPPro[2, 3], aPPro[2, 4])
@ 000, 000 Say OemToAnsi(STR0020) Size 100, 010 OF oPFLancam PIXEL COLOR CLR_BLUE  //"FORMA DE LANวAMENTO "
@ 000, 250 Say OemToAnsi(STR0021) Size 60, 010 OF oPFLancam PIXEL COLOR CLR_BLUE  //"QUANTIDADE "

oChkAsso := tCheckBox():New(000,150,OemToAnsi(STR0022), {|u|if( pcount()>0,lChkAsso:=u,lChkAsso)},oPFLancam,050,010,,{||FS_DESMARCA("lChkAsso", "oChkAvul")},,,,,,.T.)   //"Associado"
oChkAvul:= tCheckBox():New(000,200,OemToAnsi(STR0023), {|u|if( pcount()>0,lChkAvul:=u,lChkAvul)},oPFLancam,050,010,,{||FS_DESMARCA("lChkAvul", "oChkAsso")},,,,,,.T.)   //"Avulso"

oPPesqGBI	:=	tPanel():New(aPPro[3, 1], aPPro[3, 2],, oFoldPri:aDialogs[1],,,,,, aPPro[3, 3], aPPro[3, 4])
HS_GDPesqu( , , oGDGBI, oPPesqGBI, 002, .T., 2)
@ 002, 250 MSGet oQtde var nQtde Picture "@E 999.99" Size 030, 009 OF oPPesqGBI PIXEL COLOR CLR_BLACK

//Right
@ aPInfo[2, 1], aPInfo[2, 2] FOLDER oFolder2 SIZE aPInfo[2, 3], aPInfo[2, 4] Pixel Of oFoldPri:aDialogs[1] Prompts STR0024 //"Hist๓rico de Prescri็ใo M้dica"

oPPesqPed	:=	tPanel():New(aPPed[1, 1], aPPed[1, 2],, oFolder2:aDialogs[1],,,,,, aPPed[1, 3], aPPed[1, 4])
oPPesqPed:Align := CONTROL_ALIGN_TOP

oPGDPed	:=	tPanel():New(aPPed[2, 1], aPPed[2, 2],, oFolder2:aDialogs[1],,,,,, aPPed[2, 3], aPPed[2, 4])
oPGDPed:Align := CONTROL_ALIGN_ALLCLIENT

oPPedBtn	:=	tPanel():New(aPPed[3, 1], aPPed[3, 2],, oFolder2:aDialogs[1],,,,,, aPPed[3, 3], aPPed[3, 4])
oPPedBtn:Align := CONTROL_ALIGN_BOTTOM

nTamBtn  := IIF(aPInfo[2, 3]/3 < 0, -1,+1 )*aPInfo[2, 3]/3

oBtnLPre := tButton():New(002, 005        , STR0025, oPPedBtn, {|| FS_M10Leg()} , nTamBtn - 10, 15,,,, .T.)  //"Legenda Prescri็ใo"
oBtnHis  := tButton():New(002, nTamBtn+5, STR0026       , oPPedBtn, {|| Fs_RotAbq(cAtendimento, cReserv)} , nTamBtn - 10, 15,,,, .T.)  //"Hist๓rico Prescri็ใo"

oGDGHV := MsNewGetDados():New(aPPed[2, 1], aPPed[2, 2], aPPed[2, 3], aPPed[2, 4],0,,,,,,,,,, oPGDPed, aHGHV, aCGHV)
oGDGHV:oBrowse:bchange:= {||  FS_MntMed(cAtendimento, oGDGHV:aCols[oGDGHV:oBrowse:nAt, nGhvSeqPre], cCodLoc)}
oGDGHV:oBrowse:bGotFocus:= {||  FS_MntMed(cAtendimento, oGDGHV:aCols[oGDGHV:oBrowse:nAt, nGhvSeqPre], cCodLoc)}
oGDGHV:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

HS_GDPesqu( , , oGDGHV, oPPesqPed, 002)

//cuidados

@ aFoldPri[1, 1], aFoldPri[1, 2] FOLDER oFoldCui SIZE aFoldPri[1, 3], aFoldPri[1, 4] Pixel Of oFoldPri:aDialogs[3] Prompts STR0089, STR0090            //"Cuidados M้dicos"###"Prescri็ใo"
oFoldCui:Align := CONTROL_ALIGN_ALLCLIENT

//Cuidados M้dicos

oCuid  := MsNewGetDados():New(aPCuid[1, 1], aPCuid[1, 2], aPCuid[1, 3], aPCuid[1, 4], 0,,,,,, 99999,,,, oFoldCui:aDialogs[1], aHCuid , aCCuid )
oCuid:oBrowse:bchange:= {|| FS_AtuCuid(cAtendimento) }
oCuid:oBrowse:Align      := CONTROL_ALIGN_TOP

@ aPCuid[2, 1], aPCuid[2, 2] FOLDER oFoldObs SIZE aPCuid[2, 3], aPCuid[2, 4] Pixel Of oFoldCui:aDialogs[1] Prompts STR0091 //"Observa็ใo do cuidado"
oFoldObs:Align := CONTROL_ALIGN_ALLCLIENT

oObserv	:=	tPanel():New(aPCuid[2, 1], aPCuid[2, 2],, oFoldObs:aDialogs[1],,,,,, aPCuid[2, 3], aPCuid[2, 4])
oObserv:Align := CONTROL_ALIGN_ALLCLIENT

@ 000, 003 Say OemToAnsi(STR0092) Size 200, 010 OF oObserv PIXEL COLOR CLR_BLUE   //"Observa็ใo sobre a realiza็ใo do cuidado"
@ 010, 003 MSGet oObsRea var cObserv Picture "@!" Size 0500, 009 OF oObserv PIXEL COLOR CLR_BLACK

oBtnRCui := tButton():New(030, 190, STR0093, oObserv, {|| FS_ConfCui(cAtendimento)} , nTamBtn + 15 , 18,,,, .T.)  //"Registrar Realiza็ใo do Cuidado"

@ 037, 003 Say OemToAnsi(STR0094) Size 45, 010 OF oObserv PIXEL COLOR CLR_BLUE   //"Data Exec."
@ 035, 043 MSGet oDatExe var dDatExe Picture "@D" Size 035, 009 OF oObserv PIXEL COLOR CLR_BLACK

@ 037, 093 Say OemToAnsi(STR0095) Size 45, 010 OF oObserv PIXEL COLOR CLR_BLUE   //"Hora Exec."
@ 035, 133 MSGet oHorExe var cHorExe Picture "99:99" Valid HS_VldHora(cHorExe, .T.) Size 025, 009 OF oObserv PIXEL COLOR CLR_BLACK



@ aPPre[1, 1], aPPre[1, 2] FOLDER oFoldCuid SIZE aPPre[1, 3], aPPre[1, 4]-20 Pixel Of oFoldCui:aDialogs[1] Prompts STR0120 //"Observa็๕es Realizadas"


oMemObs := tMultiget():New(000, 003, {|u|if(Pcount()>0,cMemObs:=u,cMemObs)}, oFoldCuid, 375, 135,,,,RGB(250,250,210),, .T.,,,,,,.T.,,,,,.T.)


//Right
@ aPInfo[2, 1], aPInfo[2, 2] FOLDER oFoldPres SIZE aPInfo[2, 3], aPInfo[2, 4]-22 Pixel Of oFoldCui:aDialogs[1] Prompts STR0024 //"Hist๓rico de Prescri็ใo M้dica"

oPPesqPre	:=	tPanel():New(aPPed[1, 1], aPPed[1, 2],, oFoldPres:aDialogs[1],,,,,, aPPed[1, 3], aPPed[1, 4])
oPPesqPre:Align := CONTROL_ALIGN_TOP

oPGDPre	:=	tPanel():New(aPPed[2, 1], aPPed[2, 2],, oFoldPres:aDialogs[1],,,,,, aPPed[2, 3], aPPed[2, 4])
oPGDPre:Align := CONTROL_ALIGN_ALLCLIENT

oPPedHPre	:=	tPanel():New(aPPed[3, 1], aPPed[3, 2],, oFoldPres:aDialogs[1],,,,,, aPPed[3, 3], aPPed[3, 4])
oPPedHPre:Align := CONTROL_ALIGN_BOTTOM

nTamBtn  := IIF(aPInfo[2, 3]/3 < 0, -1,+1 )*aPInfo[2, 3]/3

oBtnLPres := tButton():New(002, 005        , STR0025, oPPedHPre, {|| FS_M10Leg()} , nTamBtn - 10, 15,,,, .T.)  //"Legenda Prescri็ใo"
oBtnHisP  := tButton():New(002, nTamBtn+5, STR0026       , oPPedHPre, {|| Fs_RotAbq(cAtendimento, cReserv)} , nTamBtn - 10, 15,,,, .T.)  //"Hist๓rico Prescri็ใo"

oCPres := MsNewGetDados():New(aPPed[2, 1], aPPed[2, 2], aPPed[2, 3], aPPed[2, 4],0,,,,,,,,,, oPGDPre, aHGHV, aCGHV)
oCPres:oBrowse:bchange:= {|| FS_CuiMed(cAtendimento, oCPres:aCols[oCPres:oBrowse:nAt, nGhvSeqPre]),  FS_AtuCuid(cAtendimento) }
oCPres:oBrowse:bGotFocus:= {|| FS_CuiMed(cAtendimento, oCPres:aCols[oCPres:oBrowse:nAt, nGhvSeqPre]),  FS_AtuCuid(cAtendimento) }
oCPres:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

HS_GDPesqu( , , oCPres, oPPesqPre, 002)


//Prescricao Enfermagem

oPPesPre	:=	tPanel():New(aPPreEnf[1, 1], aPPreEnf[1, 2],,  oFoldCui:aDialogs[2],,,,,, aPPreEnf[1, 3], aPPreEnf[1, 4])
oPPesPre:Align := CONTROL_ALIGN_TOP

oBtnConf := tButton():New(002, aPPreEnf[1, 2] + 280, STR0096, oPPesPre, {|| FS_GRVCONF(cAtendimento, cCodLoc) }, 050, 015,,,, .T.)   //"Confirma"
oBtnEvol := tButton():New(002, aPPreEnf[1, 2] + 350, STR0097, oPPesPre, {|| FS_CHMEVOL(cCodLoc, cQuarto, cLeito) }, 050, 015,,,, .T.) //"Evolu็ใo"

@ aPPreEnf[2, 1]+6, aPPreEnf[2, 2] FOLDER oFolIteP SIZE aPPreEnf[2, 3], aPPreEnf[2, 4]-4 Pixel Of oFoldCui:aDialogs[2] Prompts STR0098 //"Itens da Prescri็ใo"

oGDGNT  := MsNewGetDados():New(aPPreEnf[2, 1], aPPreEnf[2, 2], aPPreEnf[2, 3], aPPreEnf[2, 4], GD_UPDATE+GD_DELETE,,,"+GNT_SEQITE",,, 99999,,,, oFolIteP:aDialogs[1], aHGNT, aCGNT)
oGDGNT:oBrowse:BlDblClick := {|| FS_VldClick(cAtendimento, cCodLoc) }
oGDGNT:oBrowse:BChange:={|| IIf(oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntSituac] <> "2", oGDGnt:oBrowse:aAlter := IIF(Empty(oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntDatIni]),{"GNT_QTDADE"},{"GNT_DATINI", "GNT_HORINI", "GNT_DATFIM", "GNT_HORFIM" }), Nil ), oGDGnt:oBrowse:Refresh()}
oGDGNT:cFieldOk           := "HS_GDAtrib(oGDGNT, {{nGntStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
oGDGNT:oBrowse:bDelete    := {|| IIf(oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntSituac] <> "2", {HS_GDAtrib(oGDGNT, {{nGntStaReg, "BR_CINZA", "BR_VERDE"}}), oGDGNT:DelLine(),oGDGNT:oBrowse:Refresh()}, Nil)}

oGDGNT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

@ aPPreEnf[3, 1], aPPreEnf[3, 2] FOLDER oFolEnfe SIZE aPPreEnf[3, 3], aPPreEnf[3, 4]-20 Pixel Of oFoldCui:aDialogs[2] Prompts STR0099                  //"Cuidados Enfermagem"

oGDGNP  := MsNewGetDados():New(aPPreEnf[3, 1], aPPreEnf[3, 2], aPPreEnf[3, 3], aPPreEnf[3, 4], 0,,,,,, 99999,,,,oFolEnfe:aDialogs[1], aHGNP, aCGNP)
oGDGNP:oBrowse:BlDblClick := {|| FS_IncCuid() }
oGDGNP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

HS_GDPesqu( , , oGDGNT, oPPesPre, 002,.T.)


//Dietas

oDiet  := MsNewGetDados():New(aPCuid[1, 1], aPCuid[1, 2], aPCuid[1, 3], aPCuid[1, 4], 0,,,,,, 99999,,,, oFoldPri:aDialogs[2], aHDiet , aCDiet )
oDiet:oBrowse:bchange:= {|| FS_AtuDiet(cAtendimento) }
oDiet:oBrowse:Align      := CONTROL_ALIGN_TOP

@ aPCuid[2, 1], aPCuid[2, 2] FOLDER oFolDiet SIZE aPCuid[2, 3], aPCuid[2, 4] Pixel Of oFoldPri:aDialogs[2] Prompts STR0100 //"Observa็ใo da dieta"
oFolDiet:Align := CONTROL_ALIGN_ALLCLIENT

oPanObs	:=	tPanel():New(aPCuid[2, 1], aPCuid[2, 2],, oFolDiet:aDialogs[1],,,,,, aPCuid[2, 3], aPCuid[2, 4])
oPanObs:Align := CONTROL_ALIGN_ALLCLIENT

@ 000, 003 Say OemToAnsi(STR0101) Size 200, 010 OF oPanObs PIXEL COLOR CLR_BLUE   //"Observa็ใo sobre a realiza็ใo da Dieta"
@ 010, 003 MSGet oObsDie var cObsDie Picture "@!" Size 0500, 009 OF oPanObs PIXEL COLOR CLR_BLACK

oBtnRDie := tButton():New(030, 190, STR0102, oPanObs, {|| FS_ConfDie(cAtendimento)} , nTamBtn + 10 , 18,,,, .T.)  //"Registrar Realiza็ใo da Dieta"

@ 037, 003 Say OemToAnsi(STR0094) Size 45, 010 OF oPanObs PIXEL COLOR CLR_BLUE   //"Data Exec."
@ 035, 043 MSGet oDatDie var dDatDie Picture "@D" Size 035, 009 OF oPanObs PIXEL COLOR CLR_BLACK

@ 037, 093 Say OemToAnsi(STR0095) Size 45, 010 OF oPanObs PIXEL COLOR CLR_BLUE   //"Hora Exec."
@ 035, 133 MSGet oHorDie var cHorDie Picture "99:99" Valid HS_VldHora(cHorExe, .T.) Size 025, 009 OF oPanObs PIXEL COLOR CLR_BLACK


@ aPPre[1, 1], aPPre[1, 2] FOLDER oFoldDieta SIZE aPPre[1, 3], aPPre[1, 4] Pixel Of oFoldPri:aDialogs[2] Prompts STR0120 //"Observa็๕es Realizadas"


oMemDie := tMultiget():New(000, 003, {|u|if(Pcount()>0,cMemDie :=u,cMemDie )}, oFoldDieta, 375, 135,,,,RGB(250,250,210),, .T.,,,,,,.T.,,,,,.T.)


//Right
@ aPInfo[2, 1], aPInfo[2, 2] FOLDER oFDiePres SIZE aPInfo[2, 3], aPInfo[2, 4] Pixel Of oFoldPri:aDialogs[2] Prompts STR0024 //"Hist๓rico de Prescri็ใo M้dica"

oPrescric	:=	tPanel():New(aPPed[1, 1], aPPed[1, 2],, oFDiePres:aDialogs[1],,,,,, aPPed[1, 3], aPPed[1, 4])
oPrescric:Align := CONTROL_ALIGN_TOP

oPGPres	:=	tPanel():New(aPPed[2, 1], aPPed[2, 2],, oFDiePres:aDialogs[1],,,,,, aPPed[2, 3], aPPed[2, 4])
oPGPres:Align := CONTROL_ALIGN_ALLCLIENT

oPBotPres	:=	tPanel():New(aPPed[3, 1], aPPed[3, 2],, oFDiePres:aDialogs[1],,,,,, aPPed[3, 3], aPPed[3, 4])
oPBotPres:Align := CONTROL_ALIGN_BOTTOM

nTamBtn  := IIF(aPInfo[2, 3]/3 < 0, -1,+1 )*aPInfo[2, 3]/3

oBtnLegPr := tButton():New(002, 005        , STR0025, oPBotPres, {|| FS_M10Leg()} , nTamBtn - 10, 15,,,, .T.)  //"Legenda Prescri็ใo"
oBtnHistP := tButton():New(002, nTamBtn+5, STR0026       , oPBotPres, {|| Fs_RotAbq(cAtendimento, cReserv)} , nTamBtn - 10, 15,,,, .T.)  //"Hist๓rico Prescri็ใo"

oCDPres := MsNewGetDados():New(aPPed[2, 1], aPPed[2, 2], aPPed[2, 3], aPPed[2, 4],0,,,,,,,,,, oPGPres, aHGHV, aCGHV)
oCDPres:oBrowse:bchange:= {|| FS_Dietas(cAtendimento, oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvSeqPre]),  FS_AtuDiet(cAtendimento) }
oCDPres:oBrowse:bGotFocus:= {|| FS_Dietas(cAtendimento, oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvSeqPre]),  FS_AtuDiet(cAtendimento) }
oCDPres:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

HS_GDPesqu( , , oCDPres, oPrescric, 002)


ACTIVATE MSDIALOG oDlgM10 on init ChkNewDay(@oDlgM10, .F., "HS_CposGHX", .T.)  valid  FS_VldSai(cAtendimento)

UnLockByName("ExecM24" + cAtendimento,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",cAtendimento) 

RestKeys( aSvKeys , .T. )
Return()

Static Function FS_DESMARCA(lVar, oObj)
  Default lVar := .F.
     
  &("l"+Substr(oObj,2)) := !&(lVar)  
  &(oObj+":Refresh()")          
Return(nil)                  

                         
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ  FS_IncMed    ณ Autor ณ Mario Arizono    ณ Data ณ02/05/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ  Inclui mat/med e kit no medicamento principal correspond. ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ  .T. ou .F.                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ  Gestao Hospitalar                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                               
 
Static Function FS_IncMed(cCodLoc)
 Local aArea   := getArea()
 Local lRet    := .T.
 Local nPosGD  := 0, nFkit := 0, nPos := 0, nInicio := 1
 Local aRetKit := {}
 Local cProPri := "", cTipPro := ""       
               
 If oGDGhv:aCols[oGDGhv:oBrowse:nAt, nGhvStatus] <> "BR_PRETO"
  HS_MsgInf(STR0027, STR0002, STR0028) //"A inclusใo de novos produtos s๓ pode ser feita para prescri็๕es com status encerrado."###"Aten็ใo"###"Valida็ใo lan็amento mat/med."
  lRet := .F.
 ElseIf  Empty(oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut])
  HS_MsgInf(STR0029, STR0002, STR0028) //"Nใo existe produto para ser lan็ado. Verifique cadastro de produto campo 'GBI_ENFERM'."###"Aten็ใo"###"Valida็ใo lan็amento mat/med."
  lRet := .F.
 ElseIf  len(oGDGhx:aCols) == 0 
  HS_MsgInf(STR0103, STR0002, STR0028) //###"Aten็ใo"###"Valida็ใo lan็amento mat/med." //"A inclusใo de novos produtos s๓ pode ser feita para prescri็๕es com itens prescritos pelo m้dico."
  lRet := .F.
 ElseIf !(oGDGhx:aCols[oGDGhx:oBrowse:nAt, nGhxTpItmp] $ "1/7") .And. lChkAsso
  HS_MsgInf(STR0030, STR0002, STR0028) //"Produto nใo pode ser associado ao produto selecionado. Tipo diferente de medicamento."###"Aten็ใo"###"Valida็ใo lan็amento mat/med."
  lRet := .F.
 ElseIf nQtde == 0
  HS_MsgInf(STR0031, STR0002, STR0028) //"Quantidade invแlida."###"Aten็ใo"###"Valida็ใo lan็amento mat/med."
  lRet := .F.
 Endif
 
 
 If lRet
  
  cProPri := IIF(lChkAsso, oGDGhx:aCols[oGDGhx:oBrowse:nAt, nGhxCodPro], oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut] ) 
  cTipPro := HS_IniPadr("GBI", 1, oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut] , "GBI_TIPO") 
  aRetKit := HS_RKitMMP(oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut] , cCodLoc)[1]
  
  aCGhx := aClone(oGdGhx:aCols)
 
  If lChkAsso
   WHILE (nPos := aScan(aCGhx, {| aVet | aVet[nGhxCodPro] == cProPri}, nInicio)) > 0
  
    nInicio := nPos + 1
  
   EndDo
  Endif
 
 
  If Empty(aRetKit) 
  
   If (aScan( oGDGhx:aCols, {| aVet |  aVet[nGhxCodPro] + aVet[nGhxCodPri] == cProPri + oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut]})) > 0  .And. lChkAsso
    HS_MsgInf(STR0032, STR0002, STR0028) //"Produto selecionado jแ existe."###"Aten็ใo"###"Valida็ใo lan็amento mat/med."
    lRet := .F.
   Else
     
    aSize(aCGhx, len(aCGhx) + 1)
   
       
    If lChkAsso
     aIns(aCGhx, nInicio)
     nPosGd := nInicio
    Else
    nPosGD := len(aCGhx)
    Endif
    aCGhx[nPosGd] := {"BR_VERDE", "", "", "", "", "", "", 0, "", "", "", "", "", "", .F.}
   
    aCGhx[nPosGD, nGhxTpItmp] := IIF(lChkAsso, "6", IIF(cTipPro == "1", "1", IIF(cTipPro == "0", "7", "5")))
    aCGhx[nPosGD, nGhxCodPro] := cProPri
    aCGhx[nPosGD, nGhxCodPri] := oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut] 
    aCGhx[nPosGD, nGhxDesPro] := oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiDescri] 
    aCGhx[nPosGD, nGhxQtde]   := nQtde 
    aCGhx[nPosGD, nGhxDunico] := HS_IniPadr("SAH", 1, HS_IniPadr("SB1", 1, oGDGbi:aCols[oGDGbi:oBrowse:nAt, nGbiProdut] , "B1_UM"), "AH_UMRES")
    aCGhx[nPosGD, nGhxArmSet] := HS_IniPadr("GCS", 1, cCodLoc, "GCS_ARMSET")
   
   Endif
  Else
  
   For nFKit := 1 To Len(aretkit)
   
    cTipPro := HS_IniPadr("GBI", 1, aretkit[nFKit, 1], "GBI_TIPO") 
    
    If (aScan( oGDGhx:aCols, {| aVet | aVet[nGhxCodPri] == aretkit[nFKit, 1]})) > 0  .Or. cTipPro == "4"
     Loop
    Endif
    
    aSize(aCGhx, len(aCGhx) + 1)
   
       
    If lChkAsso
     aIns(aCGhx, nInicio)
     nPosGd := nInicio
    Else
     nPosGD := len(aCGhx)
    Endif
    aCGhx[nPosGd] := {"BR_VERDE", "", "", "", "", "", "", 0, "", "", "", "", "", "", .F.}
  
      
    aCGhx[nPosGD, nGhxTpItmp] := IIF(lChkAsso, "6", IIF(cProPri == aretkit[nFKit, 1], IIF(cTipPro == "1", "1", "7"), "5"))
    aCGhx[nPosGD, nGhxCodPro] := cProPri
    aCGhx[nPosGD, nGhxCodPri] := aretkit[nFKit, 1]
    aCGhx[nPosGD, nGhxDesPro] := HS_IniPadr("SB1", 1, aretkit[nFKit, 1], "B1_DESC" ,, .F.)
    aCGhx[nPosGD, nGhxQtde]   := nQtde
    aCGhx[nPosGD, nGhxDunico] := HS_IniPadr("SAH", 1, HS_IniPadr("SB1", 1, aretkit[nFKit, 1] , "B1_UM"), "AH_UMRES")
    aCGhx[nPosGD, nGhxArmSet] := HS_IniPadr("GCS", 1, cCodLoc, "GCS_ARMSET")
  
   nInicio ++
   
   Next
  
  Endif
 Endif                                                                                         
 
 oGDGhx:SetArray(aCGhx)
 oGDGhx:oBrowse:Refresh()    
 nQtde := 1
 oQtde:Refresh()                    
 RestArea(aArea)
Return(lRet)                



/*/         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ  FS_IncCuid   ณ Autor ณ Mario Arizono    ณ Data ณ01/07/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ  Inclui Cuidados na prescricao de enfermagem.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ  Gestao Hospitalar                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                               
 
Static Function FS_IncCuid()
 Local aArea   := getArea()
 Local lRet    := .T.  
 Local nPosGD  := 0
 Local nPos    := 0
 Local nPosDat := IIF(oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpContro] == "0", nGntDatLan, nGntDatIni) 
 Local nPosHor := IIF(oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpContro] == "0", nGntHorLan, nGntHorIni)
               
 nPos :=  aScan(oGDGnt:aCols, {| aVet | aVet[nGntCodCui] + DTOS(aVet[nPosDat]) == oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpCodCui] + DTOS(dDatabase) .And. SubHoras(time(), aVet[nPosHor] ) < 1}) 
  
 If Empty(oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpCodCui])
  HS_MsgInf(STR0104, STR0002, STR0105) //"Cuidado selecionado invแlido."###"Valida็ใo cuidado"
  lRet := .F.
 ElseIf nPos > 0
  HS_MsgInf(STR0106, STR0002, STR0105) //"Cuidado jแ foi lan็ado e nใo pode ser lan็ado novamente antes de um perํodo de 1 hora."###"Valida็ใo cuidado"
  lRet := .F.
 Else
  If Empty(oGDGnt:aCols[1, nGntCodCui])
   nPosGD := 1               
  Else
   oGDGnt:AddLine(.F.,.F.)
   oGDGnt:lNewLine := .F.
   nPosGD := Len(oGDGnt:aCols)
   
  Endif
  
  oGDGnt:aCols[nPosGD, nGntCodCui] := oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpCodCui]
  oGDGnt:aCols[nPosGD, nGntDesCui] := oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpDesCui]
  oGDGnt:aCols[nPosGD, nGntDatLan] := dDataBase
  oGDGnt:aCols[nPosGD, nGntHorLan] := Time()
  oGDGnt:aCols[nPosGD, nGntUsuari] := cUserName
  oGDGnt:aCols[nPosGD, nGntDatIni] := IIf (oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpContro] == "0", CTOD("  /  /  "), dDataBase)
  oGDGnt:aCols[nPosGD, nGntHorIni] := IIf (oGDGnp:aCols[oGDGnp:oBrowse:nAt, nGnpContro] == "0", "", Time())
  oGDGnt:aCols[nPosGD, nGntDatFim] := CTOD("  /  /  ")
  oGDGnt:aCols[nPosGD, nGntQtdade] := 1
 Endif
  
  oGDGnt:oBrowse:Refresh()
 
 RestArea(aArea)
Return(lRet)                



/*/



ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GerHead  บ Autor ณ Mario Arizono      บ Data ณ 20/02/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function FS_GerHead(aCampos, aHeader)
 Local nForCampos := 0
                             
 DbSelectArea("SX3")
 DbSetOrder(2) // X3_CAMPO 

 For nForCampos := 1 to len(aCampos)
   DbSeek(aCampos[nForCampos])
   aAdd(aHeader, { IIF ((aCampos[nForCampos] <> "GHX_QTDMED"),TRIM(X3Titulo()),IIF(aCampos[nForCampos] == "GBI_PRODUT", "Principal", "Quant/Fre"))	, ;
                   SX3->X3_CAMPO   	, ;
                   SX3->X3_PICTURE 	, ;
                   SX3->X3_TAMANHO 	, ;
                   SX3->X3_DECIMAL 	, ;
                   ""   	           , ;
                   SX3->X3_USADO   	, ;
          		       SX3->X3_TIPO    	, ;
                   SX3->X3_F3      	, ;
          		       SX3->X3_CONTEXT 	, ;
                   SX3->X3_CBOX    	, ;
   		              ""              	, ;
                   SX3->X3_WHEN    	, ;
                   SX3->X3_VISUAL  	, ;
                   SX3->X3_VLDUSER 	, ;
                   SX3->X3_PICTVAR 	, ;
                   .F. })
                
 Next nForCampos

Return(aHeader)    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_MntMed บ Autor ณ Mario Arizono      บ Data ณ 29/04/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader e Acols Medicamento.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function FS_MntMed(cRegate, cSeqPre, cCodLoc, lInicio)
 Local aArea := GetArea()
 Local cCodMed := "", cArmSet := "", cCorLeg := ""
 Local nPosGd  := 0
 
 Default lInicio := .F.
 
 If !lInicio
  Fs_MntCol()
 Endif
 
 nPosGD := aScan(aColGhx, {| aVet | aVet[1] == oGDGHV:aCols[oGDGHV:oBrowse:nAt, nGhvSeqPre]}) 
 
 If lInicio .Or. nPosGd == 0
  aCampos := {"GHX_STAENF", "GHX_TPITMP", "GHX_SOLICI", "GBI_PRODUT", "GHX_CDMEDI", "GHX_DSITEM", "GHX_APRESE", "GHX_QTDMED", "GHX_DUNICO", "GHX_IDREGI", "GHX_OBSREG", "GHX_DESMOT", "GCS_ARMSET", "GHX_ITEMBR"}   
  aHGHX   := FS_GerHead(aCampos, aHGhx, .T.)
  nUGHX   := len(aCampos)
    
  cSQL  := "SELECT GHX.GHX_STAENF, GHX.GHX_SOLICI, GHX.GHX_TPITMP, GHX.GHX_CDMEDI, GHX.GHX_APRESE, GHX.GHX_IDREGI, GHX.GHX_OBSREG, GHX.GHX_QTDMED, "
  cSQL  += " GHX.GHX_ITEMBR, SB1.B1_DESC, SAH.AH_UMRES, GHS.GHS_DESMOT "
  cSQL  += " FROM " + RetSQLName("GHX") + " GHX"
  cSQL  += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD  =  GHX.GHX_CDMEDI  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' " 
  cSQL  += " LEFT JOIN " + RetSqlName("SAH") + " SAH ON SAH.AH_UNIMED   =  GHX.GHX_CDUNIC  AND SAH.AH_FILIAL  = '" + xFilial("SAH") + "' AND SAH.D_E_L_E_T_ <> '*' " 
  cSQL  += " LEFT JOIN " + RetSqlName("GHS") + " GHS ON GHS.GHS_MOTIVO  =  GHX.GHX_MOTIVO  AND GHS.GHS_FILIAL  = '" + xFilial("GHS") + "' AND GHS.D_E_L_E_T_ <> '*' " 
  cSQL  += " WHERE GHX.GHX_FILIAL = '" + xFilial("GHX") + "' AND GHX.D_E_L_E_T_ <> '*' AND GHX.GHX_SEQPRE = '" + cSeqPre + "' "
  cSQL  += " AND GHX.GHX_REGATE = '" + cRegate + "' AND GHX.GHX_TPITMP NOT IN ('2', '3')"
  cSQL  += " ORDER BY GHX_SEQPRI, GHX_ITEMBR"
  
  TCQUERY cSQL NEW ALIAS "QRY"  
 
  DbSelectArea("QRY")
  DbGoTop()
   
  If !Empty(cCodLoc)
   cArmSet := HS_IniPadr("GCS", 1, cCodLoc, "GCS_ARMSET")
  Endif      
  
  aCGhx := {}
  
  While !Eof()
    If QRY->GHX_TPITMP $ "1/7"
     cCodMed := QRY->GHX_CDMEDI
    Endif
    
    cCorLeg := IIF(Empty(QRY->GHX_STAENF), IIF(!Empty(QRY->GHS_DESMOT), "BR_PRETO","BR_VERDE"), FS_RetLeg(aLegIte, "GHX_STAENF", QRY->GHX_STAENF)) 
       
   aAdd(aCGhx, {cCorLeg, QRY->GHX_TPITMP, QRY->GHX_SOLICI, cCodMed, QRY->GHX_CDMEDI, QRY->B1_DESC, QRY->GHX_APRESE, QRY->GHX_QTDMED, QRY->AH_UMRES, ;
                QRY->GHX_IDREGI, QRY->GHX_OBSREG, QRY->GHS_DESMOT, cArmSet, QRY->GHX_ITEMBR, .F.})

   DbSkip()
  End
   
  dBCloseArea()
  
  If !lInicio
   oGDGHX:ACols:= aClone(aCGHX)   
   oGDGHX:oBrowse:Refresh()
  Endif
 
 Else
  If !Empty(aColGhx)
   oGDGHX:SetArray(aColGhx[nPosGd, 2])    
   oGDGHX:oBrowse:Refresh()
  Endif
 Endif  
 
 If !lInicio
  nAtAnt := oGDGHV:nAt
 Endif
 
 RestArea(aArea)                                  
	
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_CuiMed บ Autor ณ Mario Arizono      บ Data ณ 25/06/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader e Acols-Cuidados Medicos          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function FS_CuiMed(cRegate, cSeqPre, lInicio)
 Local aArea := GetArea()
 Local aJoin := {}
 
 Default lInicio := .F.

 aHCuid := {}
 aCCuid := {}
 nUCuid := 0

 aJoin := {{" JOIN " + RetSqlName("GNP") + " GNP", "GNP.GNP_DESCUI", "GNP.GNP_FILIAL = '" + xFilial("GNP") + "' AND GNP.D_E_L_E_T_ <> '*' AND GNP.GNP_CODCUI = GHX.GHX_CDMEDI", "GHX_DSITEM"}}
 
 HS_BDados("GHX", @aHCuid, @aCCuid, @nUCuid, 1,, "GHX->GHX_REGATE = '"+ cRegate +"' AND GHX->GHX_SEQPRE = '"+ cSeqPre +"' AND GHX->GHX_TPITMP = '3'",,,"GHX_CDMEDI/GHX_DSITEM/GHX_ITEMBR",,,,,,.T.,,,,,,,aJoin)
 
 If !lInicio 
  oCuid:aCols := aClone(aCCuid)
  oCuid:oBrowse:Refresh()
 Endif          
 
 RestArea(aArea)                                  
	
Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_Dietas บ Autor ณ Mario Arizono      บ Data ณ 16/07/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader e Acols-Dietas                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function FS_Dietas(cRegate, cSeqPre, lInicio)
 Local aArea := GetArea()
 Local aJoin := {}
 
 Default lInicio := .F.

 aHDiet := {}
 aCDiet := {}
 nUDiet := 0


 aJoin := {{" JOIN "      + RetSqlName("SX5") + " SX5", "SX5.X5_DESCRI", "SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ <> '*' AND SX5.X5_CHAVE = GHX.GHX_CDMEDI" , "GHX_DSITEM"}}
 aJoin := {{" LEFT JOIN " + RetSqlName("GFW") + " GFW", "GFW_DESVIA", "GFW.GFW_FILIAL = '" + xFilial("GFW") + "' AND GFW.D_E_L_E_T_ <> '*' AND GFW.GFW_CODVIA = GHX.GHX_CODVIA ", "GHX_DESVIA"}}
 aJoin := {{" LEFT JOIN " + RetSqlName("GFZ") + " GFZ", "GFZ_DSFRQA", "GFZ.GFZ_FILIAL = '" + xFilial("GFZ") + "' AND GFZ.D_E_L_E_T_ <> '*' AND GFZ.GFZ_CDFRQA = GHX.GHX_CDFRQA " , "GHX_DSFRQA"}}
 aJoin := {{" LEFT JOIN " + RetSqlName("GFY") + " GFY", "GFY_DSMINF", "GFY.GFY_FILIAL = '" + xFilial("GFY") + "' AND GFY.D_E_L_E_T_ <> '*' AND GFY.GFY_CDMINF = GHX.GHX_CDMINF " , "GHX_DSMINF"}}
 
 HS_BDados("GHX", @aHDiet, @aCDiet, @nUDiet, 1,, "GHX->GHX_REGATE = '"+ cRegate +"' AND GHX->GHX_SEQPRE = '"+ cSeqPre +"' AND GHX->GHX_TPITMP = '2'",,,"GHX_CDMEDI/GHX_DSITEM/GHX_VOLUME/GHX_CDFRQA/GHX_DSFRQA/GHX_CODVIA/GHX_DESVIA/GHX_VELINF/GHX_CDMINF/GHX_DSMINF/GHX_OBSREG/GHX_ITEMBR",,,,,,.T.,,,,,,,aJoin)
 
 If !lInicio 
  oDiet:aCols := aClone(aCDiet)                                                                                                                   
  oDiet:oBrowse:Refresh()
 Endif          
 
 RestArea(aArea)                                  
	
Return()


/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MNTCOL  บ Autor ณ MARIO ARIZONO      บ Data ณ  05/05/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que guarda acols do GHX.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_MNTCOL()
 Local nPosGD := 0                 
      
  nPosGD := aScan(aColGhx, {| aVet | aVet[1] == oGDGHV:aCols[nAtAnt, nGhvSeqPre]})
  
  If nPosGD == 0
   AADD(aColGhx,{oGDGHV:aCols[nAtAnt, nGhvSeqPre], aClone(oGDGHX:aCols)})
  Else
   aColGhx[nPosGd, 2] := aClone(oGDGHX:aCols)
  Endif
  
  
Return(.T.)     

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ROTABQ  บ Autor ณ MARIO ARIZONO      บ Data ณ  06/05/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que mostra prescri็ใo posicionada.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_ROTABQ(cRegate, cReserv)
 Local aArea := GetArea()
 
 Private aRotina   := {{ "", "", 0 , 4},;
								               { "", "", 0 , 2},;
                       { "", "", 0 , 4},;
                       { "", "", 0 , 3}} 
                       
 DBSelectArea("GCY")
 DbSetOrder(1)//REGATE
 DbSeek(xFilial("GCY") + cRegate)

 HS_MntAbq("GCY", GCY->(Recno()), 2,, cReserv)
  
 RestArea(aArea)   
Return()               

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVSOL  บ Autor ณ MARIO ARIZONO      บ Data ณ  06/05/08  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณFuncao que gera solicitacoes para farmacia.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

STATIC FUNCTION FS_GRVSOL(cRegate, cCodLoc, cReserv, cNomPac, cQuarto, cLeito, cSeqPre)
Local aArea := GetArea(), aConest := {}
Local nItePres := 0 , nItemGaj := 0
Local dDatMov := CTOD("  /  /  "), dDatPre :=  CTOD("  /  /  ")
Local cHorMov := "", cAlmori := "", cProalt := "", cSolici := "", cFrePri := "", cSolIni := ""
Local cStaEnf := "", cSeqPri := "", cCodCrm := HS_IniPadr("GHV", 1, cRegate + cSeqPre, "GHV_CODCRM"), cItemBr := "", cCdUnic := ""
Local lAchouGhx := .T., lGrvGai := .T.
Local cIteSol   := "", cSeqDes := ""
Local nQtdHor   := 0

If FS_VLDSOL(cRegate, cCodLoc, cReserv, @dDatMov, @cHorMov)
	Begin Transaction
	
	DbSelectArea("GCS")
	DbSetOrder(1)
	DbSeek(xfilial("GCS")+cCodLoc)
	
	cAlmori := HS_ArmFarS(.T.)
	
	
	For nItePres := 1 To Len(oGdGhx:aCols)
		
		cStaEnf := oGdGhx:aCols[nItePres, nGhxStaEnf]
		DbSelectArea("GHX")
		DbSetOrder(1)
		lAchouGhx := DbSeek(xFilial("GHX") + oGdGhx:aCols[nItePres, nGhxItemBr] + cRegate +  cSeqPre)
		
		If oGdGhx:aCols[nItePres,  nGhxCodPro] == oGdGhx:aCols[nItePres,  nGhxCodPri]
			If lAchouGhx
				cFrePri := GHX->GHX_CDFRQA
			Else
				cFrePri := ""
			Endif
		Endif
		
		
		If !oGdGhx:aCols[nItePres, nUGHX+1] .And. oGdGhx:aCols[nItePres, nGhxStaEnf] == "BR_VERDE"
			cProalt := HS_PROALT(oGdGhx:aCols[nItePres, nGhxCodPri])
			aConest := HS_CONEST(IIF(!Empty(cProalt), cProalt, oGdGhx:aCols[nItePres, nGhxCodPri]), cCodLoc)
			
			
			dDatPre := IIF(lAchouGhx, GHX->GHX_DATPRE, dDataBase)
			cCdUnic := IIF(lAchouGhx, GHX->GHX_CDUNIC, HS_IniPadr("SB1", 1, oGdGhx:aCols[nItePres,  nGhxCodPri] , "B1_UM"))
			
			nQtdHor := FS_QTDLAN(cRegate, cSeqPre, cAlmori, cFrePri, oGdGhx:aCols[nItePres,  nGhxCodPri], oGdGhx:aCols[nItePres,  nGhxQtde], dDatPre, cCdUnic, nItePres )
			
			If aConest[1]
				
				If lGrvGai
					M->GAI_SOLICI := HS_VSxeNum("GAI", "M->GAI_SOLICI", 1)
					ConfirmSx8()
					
					cSolIni := M->GAI_SOLICI
					
					DbSelectArea("GAI")
					DbSetOrder(1)
					RecLock("GAI", .T.)
					GAI->GAI_FILIAL := xFilial("GAI")
					GAI->GAI_SOLICI := M->GAI_SOLICI
					GAI->GAI_ALMORI := cAlmori
					GAI->GAI_REQUIS := "1" // 1-Paciente
					GAI->GAI_ALMSOL := GCS->GCS_ARMSET
					GAI->GAI_REGATE := cRegate
					GAI->GAI_NOMPAC := cNomPac
					GAI->GAI_CODLOC := GCS->GCS_CODLOC
					GAI->GAI_DATSOL := dDatMov
					GAI->GAI_HORSOL := cHorMov
					GAI->GAI_FLGATE := "0"
					GAI->GAI_URGENC := "0"
					GAI->GAI_LOGARQ := HS_LogArq()
					MsUnLock()
					lGrvGai := .F.
					nItemGaj := 1
				Endif
				
				cSolici := cSolIni
				DbSelectArea("GAJ")
				DbSetOrder(1)
				
				RecLock("GAJ", .T.)
				GAJ->GAJ_FILIAL := xFilial("GAJ")
				GAJ->GAJ_SOLICI := M->GAI_SOLICI
				GAJ->GAJ_ITESOL := StrZero(nItemGaj++, Len(GAJ->GAJ_ITESOL))
				GAJ->GAJ_PROSOL := oGdGhx:aCols[nItePres, nGhxCodPri]
				GAJ->GAJ_QTDSOL := nQtdHor
				GAJ->GAJ_PROALT := cProalt
				If HS_ExisDic({{"C", "GAJ_CODCRM"}}, .F.)
					GAJ->GAJ_CODCRM := cCodCrm
				EndIf
				If HS_ExisDic({{"C", "GAJ_ITEPRE"}}, .F.)
					GAJ->GAJ_ITEPRE := GAJ->GAJ_ITESOL
				EndIf
				GAJ->GAJ_LOGARQ := HS_LogArq()
				MsUnLock()
				cSeqDes := ""
				cIteSol := GAJ->GAJ_ITESOL
				cStaEnf := "1"
			Else
				cStaEnf := "2"
				cIteSol := ""
				cSolici := ""
				
				DbSelectArea("GCZ")
				DbSetOrder(9) // GCZ_FILIAL + GCZ_STATUS + GCZ_REGATE + GCZ_CODCON + GCZ_CODPLA
				DbSeek(xFilial("GCZ") + "0" + cRegate) // Procura primeira guia em aberto.
				
				DbSelectArea("GCY")
				DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
				DbSeek(xFilial("GCY") + cRegate)
				
				aRValDes := HS_RValMM(GCZ->GCZ_CODPLA, oGdGhx:aCols[nItePres, nGhxCodPri],,, dDatMov,, cCodCrm, cCodLoc, cHorMov,{GCY->GCY_ATENDI, GCY->GCY_CARATE})
				DbSelectArea("GD5")
				DbSetOrder(1) // GD5_FILIAL + GD5_SEQDES
				
				M->GD5_SEQDES := HS_VSxeNum("GD5", "M->GD5_SEQDES", 1)
				ConfirmSx8()
				
				cSeqDes := M->GD5_SEQDES
				
				RecLock("GD5", .T.)
				GD5->GD5_FILIAL := xFilial("GD5")
				GD5->GD5_CODLOC := cCodLoc
				GD5->GD5_DATDES := dDatMov
				GD5->GD5_HORDES := cHorMov
				GD5->GD5_QTDDES := nQtdHor
				GD5->GD5_CODDES := oGdGhx:aCols[nItePres, nGhxCodPri]
				GD5->GD5_VALDES := aRValDes[2]
				GD5->GD5_PCUDES := aRValDes[3]
				GD5->GD5_PERTRO := "0"
				GD5->GD5_PROALT := cProalt
				GD5->GD5_GLODES := IIf(aRValDes[4][1], "2", "0")
				GD5->GD5_SEQDES := M->GD5_SEQDES
				GD5->GD5_NRSEQG := GCZ->GCZ_NRSEQG
				GD5->GD5_REGATE := cRegate
				GD5->GD5_FATPAR := aRValDes[4][2]
				GD5->GD5_CODPRO := aRValDes[9]
				GD5->GD5_DESPRO := aRValDes[10]
				GD5->GD5_TABELA := aRValDes[11]
				GD5->GD5_LOGARQ := HS_LogArq()
				If HS_ExisDic({{"C", "GD5_CODCRM"}}, .F.)
					GD5->GD5_CODCRM := cCodCrm
					GD5->GD5_VALREP := oGdGhx:aCols[nItePres, nGhxQtde] * aRValDes[13][05]
					GD5->GD5_VALREB := GD5->GD5_VALREP
					GD5->GD5_PGTMED := aRValDes[13][01]
					GD5->GD5_REPAMB := aRValDes[13][aRValDes[15]]
				EndIf
				MsUnLock()
				
			Endif
			
			DbSelectArea("GHX")
			
			
			RecLock("GHX", !lAchouGHX)
			
			If lAchouGhx
				GHX->GHX_SOLICI  := cSolici
				GHX->GHX_STAENF  := cStaEnf
				GHX->GHX_ITEGAJ  := cIteSol
				GHX->GHX_SEQDES  := cSeqDes
				cItemBr          := ""
			Else
				
				cItemBr := FS_MaxItem(cSeqPre, cRegate)
				cItemBr := Soma1(cItemBr, len(GHX->GHX_ITEMBR))
				
				GHX->GHX_FILIAL  := xFilial("GHX")
				GHX->GHX_SOLICI  := cSolici
				GHX->GHX_STAENF  := cStaEnf
				GHX->GHX_ITEMBR  := cItemBr
				GHX->GHX_TPITMP  := oGdGhx:aCols[nItePres,  nGhxTpItmp]
				GHX->GHX_CDMEDI  := oGdGhx:aCols[nItePres,  nGhxCodPri]
				GHX->GHX_DATPRE  := dDatabase
				GHX->GHX_REGATE  := cRegate
				GHX->GHX_STATUS  := "1"
				GHX->GHX_SEQPRE  := cSeqPre
				GHX->GHX_QTDMED  := oGdGhx:aCols[nItePres, nGhxQtde]
				GHX->GHX_CDUNIC  :=  cCdUnic
				GHX->GHX_TPUSUA  := "2"
				GHX->GHX_ITEGAJ  := cIteSol
				GHX->GHX_SEQDES  := cSeqDes
				
				GHX->GHX_SEQPRI  := IIf (oGdGhx:aCols[nItePres,  nGhxCodPro] <> oGdGhx:aCols[nItePres,  nGhxCodPri], cSeqPri, cItemBr)
				
			Endif
			
			MsUnlock()
			
			HS_CposGHX(cSeqPre, nItePres, cSolici, FS_RetLeg(aLegIte, "GHX_STAENF", cStaEnf), cItemBr, cSeqDes)
			
			If oGdGhx:aCols[nItePres,  nGhxCodPro] == oGdGhx:aCols[nItePres,  nGhxCodPri]
				cSeqPri :=  GHX->GHX_ITEMBR
			Endif
			
		Else
			If oGdGhx:aCols[nItePres,  nGhxCodPro] == oGdGhx:aCols[nItePres,  nGhxCodPri]
				cSeqPri :=  oGdGhx:aCols[nItePres,  nGhxItemBr]
			Endif
		Endif
		
	Next
	End Transaction
Else
	Return(nil)
Endif

If Type("M->GAI_SOLICI") # "U" .And. !Empty(M->GAI_SOLICI)
	HSPAHR03(M->GAI_SOLICI,"","",Posicione("SX1", 1, "HSPR0302", "X1_PRESEL"))
	If ExistBlock("HSPHRAP03")
		Execblock("HSPHRAP03", .F., .F., {M->GAI_SOLICI})
	EndIf
Endif

aCghx := aClone(oGdGhx:aCols)

RestArea(aArea)
Return()          

Static Function FS_M10Leg()
 BrwLegenda(STR0033,STR0034, {	{"BR_VERDE"   ,	STR0035 },;	  //"Prescri็ใo M้dica"###"Legenda"###"Ativa"
 								{"BR_VERMELHO" ,	STR0036},;	   //"Suspensa"
 								{"BR_AZUL"     ,	STR0037},;	  //"Administrada"
 								{"BR_PINK"     ,	STR0142},;	  //"Atrasada"
 								{"BR_CINZA"    ,	STR0038}}) //"Encerrada"

Return(.T.)              


Static Function FS_LegIte()
 BrwLegenda(STR0039,STR0034, {	{"BR_VERDE"   ,	STR0040 },;	  //"Itens Prescri็ใo M้dica"###"Legenda"###"Pendente"
						       {"BR_AMARELO" ,	STR0041},;	   //"Solicitado"
						       {"BR_VERMELHO",	STR0042},; //"Atendido"
						       {"BR_PRETO"   , STR0043},; //"Suspenso"
						       {"BR_MARROM"  , STR0044}}) //"Parcialmente Atendido"
 																																       

Return(.T.)         

Static Function FS_LegHor()

 BrwLegenda(STR0045,STR0034, {	{"BR_VERDE"   ,	STR0040 },;	  //"Legenda status horแrios"###"Legenda"###"Pendente"
						       {"BR_AMARELO" ,	STR0041},;	   //"Solicitado"
						       {"BR_VERMELHO",	STR0042},; //"Atendido"
						       {"BR_PRETO"   , STR0043}}) //"Suspenso"
 																																       
							 																																       

Return(.T.)         



/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_VldDel ณ Autor ณ Mario Arizono         ณ Data ณ 07.05.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida็ใo da exclusใo de item prescricao                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณFS_VldDel()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณHSPAHM10                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_VldDel(cLegend, cSeqIte )
 Local lRet := .T.
 
 If !(cLegend $ "BR_VERDE/BR_CINZA")
  HS_MsgInf(STR0046, STR0002, STR0047) //"Nใo ้ permitido excluir item com status diferente de pendente."###"Aten็ใo"###"Valida็ใo exclusใo mat/med."
  lRet := .F.
 ElseIf !Empty(cSeqIte)
  HS_MsgInf(STR0048, STR0002,  STR0047) //"Nใo ้ permitido excluir item lan็ado pela rotina de prescri็ใo m้dica."###"Aten็ใo"###"Valida็ใo exclusใo mat/med."
  lRet := .F.
 Endif
 
Return (lRet)
     
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_VldSol ณ Autor ณ Mario Arizono         ณ Data ณ 08.05.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida็ใo lancamento itens na solicitacao posto enfermagem.ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณHSPAHM10                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_VldSol(cRegate, cCodLoc, cReserv, dDatMov, cHorMov)
 Local lRet    := .T.
 Local aRetCon := {}                                

 aRetCon := HS_ConMed(cRegate, cReserv)
  
 If aRetCon[8]  == "2" //Tipo de atendimento
  dDatMov := aRetCon[1] //Data atendimento
  cHorMov := aRetCon[2] //Hora atendimento
 Else
  dDatMov := dDatabase 
  cHorMov := Time()
 Endif
   
 If !(lRet := !(aRetCon[5] == "99")) //Tipo alta
  HS_MsgInf(STR0049, STR0002, STR0050)  //"Atendimento cancelado."###"Aten็ใo"###"Solicita็ใo de Materiais e Medicamentos"
 ElseIf !Empty(aRetCon[7]) .AND. !(lRet := !(!(dDatMov > aRetCon[7])))
  HS_MsgInf(STR0051, STR0002, STR0050)   //"Data de solicita็ใo menor ou igual ao ๚ltimo fechamento de estoque, nใo serแ possํvel efetuar o lan็amento."###"Aten็ใo"###"Solicita็ใo de Materiais e Medicamentos"
 ElseIf !Empty(aRetCon[3]) .And. !(lRet := !(Alltrim(aRetCon[6]) == "N") )  
  HS_MsgInf(STR0052, STR0002, STR0050)  //"Atendimento com alta. Verifique parโmetro 'MV_LMMALTA'"###"Aten็ใo"###"Solicita็ใo de Materiais e Medicamentos"
 ElseIf !Empty(aRetCon[3]) .And. Alltrim(aRetCon[6]) == "S"//Data alta ## Parametro alta
  If dDatMov== aRetCon[3] .And. cHorMov > aRetCon[4]          
   M->GAI_HORSOL := aRetCon[4]            
  Endif 
  If !(lRet := !(dDatMov >  aRetCon[3] .Or. (dDatMov ==  aRetCon[3] .And. cHorMov > aRetCon[4])))
   HS_MsgInf(STR0053, STR0002, STR0050)  //"Solicita็ใo nใo pode ser gerada com data posterior a data da alta."###"Aten็ใo"###"Solicita็ใo de Materiais e Medicamentos"
  Endif
 Endif
         
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CposGHXบ Autor ณ Mario Arizono      บ Data ณ  09/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza campos solicita e flag ghx.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function HS_CposGHX(cSeqPre, nPosGhx, cSolici, cStatus, cItemBr, cSeqDes)
 Local aArea   := GetArea()
 
 Default cSeqPre := ""
 Default cSolici := ""
 Default nPosGhx := 0
 Default cItemBr := ""
 
 cSeqPre := IIF(Empty(cSeqPre), oGDGHV:aCols[oGDGHV:nAt, nGhvSeqPre], cSeqPre)
 
 If !Empty(cSolici) .Or. !Empty(cSeqDes)
  oGDGHX:aCols[nPosGhx, nGhxSolici] := cSolici
  oGDGHX:aCols[nPosGhx, nGhxStaEnf] := cStatus
  If !Empty(cItemBr)
  oGDGHX:aCols[nPosGhx, nGhxItemBr] := cItemBr
  Endif
 Else
  DbSelectArea("GHX")
  DbSetOrder(1)             
  
  For nPosGhx := 1 to len(oGDGHX:aCols)
   If DbSeek(xFilial("GHX") + oGDGHX:aCols[nPosGhx, nGhxItemBr] + cRegaten + cSeqPre)
    If !Empty(GHX->GHX_SOLICI)
     oGDGHX:aCols[nPosGhx, nGhxSolici] := GHX->GHX_SOLICI
     oGDGHX:aCols[nPosGhx, nGhxStaEnf] := FS_RetLeg(aLegIte, "GHX_STAENF", GHX->GHX_STAENF)
    Endif
   Endif
  Next nPosGhx     
 Endif
 oGDGHX:oBrowse:Refresh() 
  
 RestArea(aArea)
Return(Nil)                      

Static Function FS_MaxItem(cSeqPre, cRegate)
 Local cSql  := "", cItemBr := ""
 Local aArea := GetArea()
 
 cSql := " SELECT MAX(GHX.GHX_ITEMBR) CODITE "
 cSql += "   FROM "+RetSqlName("GHX")+" GHX "
 cSql += "  WHERE GHX.GHX_FILIAL = '"+xFilial("GHX")+"' "
 cSql += "    AND GHX.GHX_SEQPRE = '" + cSeqPre + "' AND GHX.GHX_REGATE =  '" + cRegate + "' "
 cSql += "    AND GHX.D_E_L_E_T_ <> '*' "
   
 cSql := ChangeQuery(cSql)
 TCQUERY cSQL NEW ALIAS "QRY"  

 DbSelectArea("QRY")

 cItemBr := QRY->CODITE         
    
 DbCloseArea()

 RestArea(aArea)
Return(cItemBr)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MntHor บ Autor ณ Mario Arizono      บ Data ณ  12/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta tela de horแrios da tela de enfermagem.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function FS_MntHor(cNomPac, cCodLoc,cRegate, cSeqPre, aColsGhx)
 Local aArea   := GetArea()
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aHorGHX := {}, aCHorGHX := {}
 Local nUHorGHX := 0
 Local cAlmori := "", cHorPad := ""
 
 Private  oGDHor
 Private cAtendi := cRegate, cSequen := cSeqPre
 
 aHorMarc := {}
  
 DbSelectArea("GCS")
 DbSetOrder(1)
 Dbseek(xFilial("GCS") + cCodLoc)
 
 cAlmori := HS_ArmFarS(.T.) 
 
 If Empty(cAlmori)
  Hs_MsgInf(STR0054 +ALLTRIM(cCodLoc) + STR0055, STR0002, STR0056)  //"Setor ["###"] nใo possui armaz้m da farmแcia cadastrado."###"Aten็ใo"###"Valida็ใo horแrios prescri็ใo."
  Return(Nil)
 Else
  If Empty(cHorPad := FS_RetHPad(cAlmori))
   Hs_MsgInf(STR0117+ ALLTRIM(cCodLoc) + STR0118, STR0002, STR0056)  //"Setor ["##"] nใo possui horแrio padrใo cadastrado na farmแcia sat้lite correspondente. Verifique!"##"Aten็ใo"###"Valida็ใo horแrios prescri็ใo."
   Return(Nil)
  Endif
 Endif

 FS_MntCHor(@aHorGHX, @aCHorGhx, cAlmori, cRegate, cSeqPre)        
 
 nUHorGHX := len(aHorGhx) 
 
 aSize 			:= MsAdvSize(.T.)
 
 aObjects := {}
 aAdd( aObjects, { 100, 085, .T., .T., .T.} )
 aAdd( aObjects, { 100, 015, .T., .T.} )
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 DEFINE MSDIALOG oDlgHor TITLE STR0057 + ALLTRIM(cNomPac) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel    //"Horแrios - "
             
  
  @ aPObjs[1, 1], aPObjs[1, 2] FOLDER oFolHor SIZE aPObjs[1, 3], aPObjs[1, 4] Pixel Of oDlgHor Prompts STR0058 //"Atendimento Farmแcia/Controle Administra็ใo"
  oFolHor:Align      := CONTROL_ALIGN_TOP                  
  

  oGDHor  := MsNewGetDados():New(aPPanel[1, 1], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0,,,,,, 99999,,,, oFolHor:aDialogs[1], aHorGHX, aCHorGHX)
  oGDHor:oBrowse:BlDblClick := {|| FS_DblClk(oGDHor:oBrowse:nAt, nUHorGHX, oGdHor, cRegate, cSeqPre)}
  oGDHor:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT  
  
     
  oMntBot	:=	tPanel():New(aPPanel[2, 1], aPPanel[2, 2],, oDlgHor,,,,,, aPPanel[2, 3], aPPanel[2, 4])
  oMntBot:Align := CONTROL_ALIGN_ALLCLIENT
  
  oBtnHMar := tButton():New(002, aPPanel[1, 1] + 15, STR0059, oMntBot, {|| FS_GERDEV(cRegate, cSeqPre, cCodLoc) }, 100, 020,,,, .T.)  //"Gerar Sol. de Dev. Prod./Hor. Marcados"
  oBtnHor  := tButton():New(002, aPPanel[1, 1] + 127, STR0060, oMntBot, {|| FS_ConAdm(oGDHor, cRegate, cSeqPre)}, 80, 020,,,, .T.) //"Confirma Aplic. Med."
  oBtnLeg  := tButton():New(002, aPPanel[1, 1] + 220, STR0034, oMntBot, {|| FS_LegHor()}, 050, 020,,,, .T.) //"Legenda"
  
 oDlgHor:bStart := { || oGDHor:Refresh()} 
 
 ACTIVATE MSDIALOG oDlgHor on init (ChkNewDay(@oDlgHor, .F., "HS_CposGnr", .T.), EnchoiceBar(oDlgHor, 	{|| oDlgHor:End()}, ;
																																																													                                     					{|| oDlgHor:End()})) 

  
 RestArea(aArea)
Return(Nil)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MntCHor บ Autor ณ Mario Arizono     บ Data ณ  15/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta aheader e acols da tela de enfermagem.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Static Function FS_MntCHor(aHeadHor, aColHor, cAlmori, cRegate, cSeqPre)

 Local nCont := 0, nQtdHDis := 24
 
 DbSelectArea("SX3")
 DbSetOrder(2) // X3_CAMPO   
 
 DbSeek("GHX_ITEMBR")
 
 aAdd(aHeadHor,	{"Item", "HSPITEMBR", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "","A"})   //"Item"
 
 DbSeek("GHX_CDMEDI")
  
 aAdd(aHeadHor,	{STR0009, "HSPCODMED", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "","A"})   //"Codigo"
 
 DbSeek("GHX_DSITEM") 

 aAdd(aHeadHor,	{STR0061, "HSPDESMED", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "", "A"})   //"Descri็ใo"

 DbSeek("GHX_APRESE")
 
 aAdd(aHeadHor,	{STR0062, "HSPAPREMED", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "", "A"})  //"Apresentacao"
 		                
 DbSeek("GMJ_HORAGE")
  
 For nCont := 1 To nQtdHDis
  
  aAdd(aHeadHor,	{STR0063, "HSPDEV" + StrZero(nCont, 3), "@BMP", 4, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "", "A"})  //"Dev"
  aAdd(aHeadHor,	{STR0064, "HSPADM" + StrZero(nCont, 3), "@BMP", 4, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "", "A"}) //"LEGENDA" //"Adm"
 	aAdd(aHeadHor,	{" ", "HSPLEG" + StrZero(nCont, 3), "@BMP", 1, SX3->X3_DECIMAL, , , SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "", "A"}) 
	 aAdd(aHeadHor,	{STR0065, "HSPHOR" + StrZero(nCont, 3), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, ,, SX3->X3_TIPO, "", SX3->X3_CONTEXT, SX3->X3_CBOX, "", "", "A"}) //"HORARIOS" //"Hora"
 Next nCont		                

  FS_HorPad(cAlmori, cRegate, cSeqPre, @aColHor, nQtdHDis)


Return(.T.)         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_HorPad บ Autor ณ Mario Arizono      บ Data ณ  15/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna acols com horแrios montados.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_HorPad(cAlmori, cRegate, cSeqPre, aColHor, nDisp)
 Local aArea   := GetArea()
 Local nPos    := "", nPosIte := 0 
 Local cCdFrqa := ""
 Local dDatPre := CTOD("  /  /  ")
  
 For nPos := 1 to len(oGDGhx:aCols)
  If !Empty(oGdGhx:aCols[nPos, nGhxItemBr]) .And.  !(oGdGhx:aCols[nPos, nUGHX+1])
   dDatPre := HS_INIPADR("GHX", 1,oGdGhx:aCols[nPos, nGhxItemBr] + cRegate +  cSeqPre, "GHX_DATPRE",, .F.) 
   
   If oGdGhx:aCols[nPos,  nGhxCodPri] == oGdGhx:aCols[nPos,  nGhxCodPro]    
    cCdFrqa := GHX->GHX_CDFRQA
   Endif
   
    Aadd(aColHor,{oGdGhx:aCols[nPos,  nGhxItemBr], oGdGhx:aCols[nPos,  nGhxCodPri], oGdGhx:aCols[nPos,  nGhxDespro], oGdGhx:aCols[nPos,  nGhxAprese]})
	 
	   For nPosITe := 1 to nDisp
	    aAdd(aColHor[len(aColHor)], "") 
	    aAdd(aColHor[len(aColHor)], "")
	    aAdd(aColHor[len(aColHor)], "")
	    aAdd(aColHor[len(aColHor)], "")
     If nPosIte == nDisp
      aAdd(aColHor[len(aColHor)], .F.)
     Endif 
    Next nPosIte
   
   FS_TABHOR(cCdFrqa, cAlmori, dDatPre, .T., , cRegate, cSeqPre, nPos, @aColHor) 
   
  Endif
 Next nPos
 
 RestArea(aArea)
                    
Return()              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_GrvGhx บ Autor ณ Mario Arizono      บ Data ณ  15/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava registros na Ghx, pelo botใo sair.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_GrvGhx(cRegate)
 Local aArea   := GetArea() 
 Local nPosIni := 0, nPosItem := 0
 Local cItemBr := "", cSeqPre := "", cSeqPri := ""
 
 Fs_MntCol()
 
 Begin Transaction
 
  For nPosIni := 1 to len(aColghx)
                                                                        	
    cSeqPre := aColGhx[nPosIni, 1]
  
   For nPosItem := 1 to len(aColghx[nPosIni, 2])
    
    cItemBr := aColghx[nPosIni, 2, nPosItem,  nGhxItemBr]
   
    If aColghx[nPosIni, 2, nPosItem,  nGhxStaEnf] == "BR_VERDE"  .And. Empty(aColghx[nPosIni, 2, nPosItem,  nGhxItemBr])
    
     cItemBr := FS_MaxItem(cSeqPre, cRegate)
     cItemBr := Soma1(cItemBr, len(GHX->GHX_ITEMBR))
    
     DbSelectArea("GHX")
     DbSetOrder(1) 
   
     RecLock("GHX", .T.)
      GHX->GHX_FILIAL  := xFilial("GHX")  
	     GHX->GHX_STAENF  := "0"
	     GHX->GHX_ITEMBR  := cItemBr
	     GHX->GHX_TPITMP  := aColghx[nPosIni, 2, nPosItem,  nGhxTpItmp]
	     GHX->GHX_CDMEDI  := aColghx[nPosIni, 2, nPosItem,  nGhxCodPri]
 	    GHX->GHX_DATPRE  := dDatabase
 	    GHX->GHX_REGATE  := cRegate
      GHX->GHX_STATUS  := "1" 
      GHX->GHX_CDUNIC  :=  HS_IniPadr("SB1", 1, aColghx[nPosIni, 2, nPosItem,  nGhxCodPri] , "B1_UM") 
	     GHX->GHX_SEQPRE  := cSeqPre
	     GHX->GHX_QTDMED  := aColghx[nPosIni, 2, nPosItem, nGhxQtde] 
      GHX->GHX_TPUSUA := "2"     
  	   GHX->GHX_SEQPRI  :=   IIf (aColghx[nPosIni, 2, nPosItem,  nGhxCodPro] <> aColghx[nPosIni, 2, nPosItem,  nGhxCodPri], cSeqPri, cItemBr)
         
     MsUnlock()
    Endif
    
    If aColghx[nPosIni, 2, nPosItem,  nGhxCodPro] == aColghx[nPosIni, 2, nPosItem,  nGhxCodPri]
     cSeqPri :=  cItemBr 
    Endif
    
   Next nPosItem
  Next nPosIni
 End Transaction
 RestArea(aArea)                   
Return()              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_TabHor บ Autor ณ Mario Arizono      บ Data ณ  15/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava tabela de horแrios.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_TABHOR(cCdFrqa, cAlmori, dDatPre, lBotHor, nQtdHor, cRegate, cSeqPre, nPos, aColHor) 
 Local aArea   := GetArea(), aCalcDat := {}
 Local cMin    := ""  
 Local cHorPad := ""
 Local dDatIni := CTOD("  /  /  "), dDatLim := CTOD("  /  /  ")
 Local cHorLim := "", cHorIni  := ""  
 Local aPosCol := {5, 6, 7, 8}
  
 Default lBotHor := .F.
 Default nQtdHor := 0
 Default aColHor := {}

 cHorPad := FS_RetHPad(cAlmori)
 
 DbSelectArea("GFZ")
 DbSetOrder(1)
 If !Empty(cCdFrqa) 
  Dbseek(xFilial("GFZ") + cCdFrqa)
  
  If GFZ->GFZ_UNFRQA =="M" 
   If GFZ->GFZ_PEFRQA > 59
    cMin:= STRZERO((GFZ->GFZ_PEFRQA / 60),2)+"."+STRZERO((Mod(GFZ->GFZ_PEFRQA,60)*60),2)
   Else
    cMin:="00."+STRZERO(GFZ->GFZ_PEFRQA,2)
   EndIf  
  Else
   cMin:= STRZERO(GFZ->GFZ_PEFRQA,2) +".00"
  EndIf  
  
  dDatIni  := dDatPre
  cHorIni  := cHorPad
  dDatLim  := dDatPre
  cHorLim  := cHorPad
 
  While (dDatIni == dDatLim .And. cHorIni < "24:00") .Or. (dDatIni < dDatLim .And. cHorLim < cHorIni )
   
   Fs_GrvGnr(cSeqPre, cRegate, nPos, cHorLim, dDatLim, @aColHor,aPosCol, lBotHor)
   
   nQtdHor++
   
   
   aCalcDat := HS_CALCDAT(dDatLim, cHorLim, "+",cMin)
    
   cHorLim  :=  IIF(SUBSTR(aCalcDat[2], 1,2) == "24", STRTRAN(aCalcDat[2], "24", "00"), aCalcDat[2])   
   dDatLim  :=  IIF(SUBSTR(aCalcDat[2], 1,2) == "24", aCalcDat[1] + 1, aCalcDat[1])    
   
   aPosCol[1] :=  aPosCol[1] + 4
   aPosCol[2] :=  aPosCol[2] + 4
   aPosCol[3] :=  aPosCol[3] + 4
   aPosCol[4] :=  aPosCol[4] + 4
  End  
 Else
  Fs_GrvGnr(cSeqPre, cRegate, nPos, "", dDatPre, @aColHor, aPosCol, lBotHor)
 Endif
  
 RestArea(aArea)
Return()                                                  

Static Function Fs_GrvGnr(cSeqPre, cRegate, nPos, cHora, dDatPre, aColRet, aPosCol, lBotHor)
Local lAchouGnr := .T.
Local cStaGnr   := "", cSeqDes := ""
Local aArea     := GetArea()
Local cItemBr   := ""
Local nPosGbe   := 0
Local nPosGnr   := 0

If oGdGhx:aCols[nPos,  nGhxStaEnf] == "BR_MARROM"
	cStaGnr := "1"
Else
	cStaGnr := Str(aScan(aLegGnr, {| aVet | aVet[2] == oGdGhx:aCols[nPos,  nGhxStaEnf]}) - 1, 1)
Endif

If Empty(oGdGhx:aCols[nPos,  nGhxItemBr])
	cItemBr := FS_MaxItem(cSeqPre, cRegate)
	cItemBr := Soma1(cItemBr, len(GHX->GHX_ITEMBR))
Endif

DbSelectArea("GNR")
DbSetOrder(1)
lAchouGnr := DbSeek(xFilial("GNR") + cRegate + cSeqPre + IIF(!Empty(cItemBr), cItemBr, oGdGhx:aCols[nPos,  nGhxItemBr]) + oGdGhx:aCols[nPos,  nGhxCodPri] + DTOS(dDatPre) + cHora)

If !lAchouGnr
	RecLock("GNR", .T.)
	GNR->GNR_FILIAL := xFilial("GNR")
	GNR->GNR_PRODUT := oGdGhx:aCols[nPos,  nGhxCodPri]
	GNR->GNR_DEVOLV := "0"
	GNR->GNR_ADMINI := "0"
	GNR->GNR_QTDATE := IIF(cStaGnr == "2", oGdGhx:aCols[nPos, nGhxQtde], 0)
	GNR->GNR_STATUS := cStaGnr
	GNR->GNR_HORPRE := cHora
	GNR->GNR_REGATE := cRegate
	GNR->GNR_SEQPRE := cSeqPre
	GNR->GNR_DATPRE := dDatPre
	GNR->GNR_ITEPRE := IIF(!Empty(cItemBr), cItemBr, oGdGhx:aCols[nPos,  nGhxItemBr])
	MsUnlock()
Else
	cSeqDes := HS_INIPADR("GHX", 1,GNR->GNR_ITEPRE + cRegate +  cSeqPre, "GHX_SEQDES",, .F.)
	DbSelectArea("GNR")
	RecLock("GNR", .F.)
	If !(GNR->GNR_STATUS $ "2/3")
		If !Empty(GNR->GNR_HORPRE)
			GNR->GNR_STATUS := cStaGnr
		Endif
		If cStaGnr == "2"
			GNR->GNR_SEQDES := cSeqDes
		Endif
	Endif
	
	MsUnlock()
	
Endif
If lBotHor
	If !Empty(GNR->GNR_HORPRE)
		aColRet[len(aColRet), aPosCol[1]] := IIF(GNR->GNR_DEVOLV == "0", "LBNO", "LBTIK")
		aColRet[len(aColRet), aPosCol[2]] := IIF(GNR->GNR_ADMINI == "0", "LBNO", "LBTIK")
		aColRet[len(aColRet), aPosCol[3]] := FS_RetLeg(aLegGnr, "GNR_STATUS", GNR->GNR_STATUS)
		aColRet[len(aColRet), aPosCol[4]] := GNR->GNR_HORPRE
	Else
		nPosGnr := aScan(aHorMarc, {|aVet| aVet[13] + aVet[1] +  aVet[2] == GNR->GNR_ITEPRE + GNR->GNR_PRODUT + GNR->GNR_HORPRE})
		If nPosGnr == 0
			Aadd(aHorMarc,{oGdGhx:aCols[nPos,  nGhxCodPri], "", "", "",  oGdGhx:aCols[nPos,  nGhxDespro], GNR->GNR_QTDATE, GNR->GNR_QTDDEV, GNR->GNR_QTDADM, cSeqDes, GHX->GHX_SOLICI, GHX->GHX_ITEGAJ, ,GNR->GNR_ITEPRE, .F.})
		Else
			aHorMarc[nPosGnr, 7] :=  GNR->GNR_QTDDEV
		Endif
	Endif
Endif
RestArea(aArea)
Return(Nil)
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DbClk บ Autor ณ Mario Arizono      บ Data ณ  20/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca devolucao e administracao produto.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(nMar, nUHorGHX,oObj, cRegate, cSeqPre)
 Local nPosLeg := 0, nPosHor := 0, nPosDev := 0 , nPosAdm := 0, nPos := 0
 Local lRet    := .T.
 Local cTpMarc := ""
 Local aArea   := GetArea()
 Local cSolici := ""
 
 cTpMarc := SUBSTR(oObj:aHeader[oObj:oBrowse:nColPos, 2],1,6)
 nPosLeg    := aScan(oObj:aHeader, {| aVet | aVet[2] == "HSPLEG"+SUBSTR(oObj:aHeader[oObj:oBrowse:nColPos, 2],7,3) })
 nPosHor    := aScan(oObj:aHeader, {| aVet | aVet[2] == "HSPHOR"+SUBSTR(oObj:aHeader[oObj:oBrowse:nColPos, 2],7,3) })
 nPosDev    := aScan(oObj:aHeader, {| aVet | aVet[2] == "HSPDEV"+SUBSTR(oObj:aHeader[oObj:oBrowse:nColPos, 2],7,3) })
 nPosAdm    := aScan(oObj:aHeader, {| aVet | aVet[2] == "HSPADM"+SUBSTR(oObj:aHeader[oObj:oBrowse:nColPos, 2],7,3) })
 nHorCdMedi := aScan(oObj:aHeader, {| aVet | aVet[2] == "HSPCODMED"})
 nHorItemBr := aScan(oObj:aHeader, {| aVet | aVet[2] == "HSPITEMBR"})
 
 DBSelectArea("GNR")
 DbSetOrder(2) 
    
 If oObj:aCols[nMar, oObj:oBrowse:nColPos] $ "LBTIK/LBNO" .and. !oObj:aCols[nMar,nUHorGHX+1]
  If cTpMarc $ "HSPDEV/HSPADM" 
  
   DbSeek(xFilial("GNR") + cRegate + cSeqPre + oObj:aCols[nMar, nHorItemBr]+ oObj:aCols[nMar, nHorCdMedi] +  oObj:aCols[nMar, nPosHor])
  
   If !(oObj:aCols[nMar, nPosLeg] $ "BR_VERMELHO") .And. !(oObj:aCols[nMar, nPosLeg] == "BR_PRETO" .And. cTpMarc == "HSPDEV")
    Hs_MsgInf(STR0066+ IIF(cTpMarc == "HSPDEV", STR0067, STR0068), STR0002, STR0069) //"Para o status atual, o produto nใo pode ser "###"devolvido."###"administrado."###"Aten็ใo"###"Valida็ใo marca็ใo de horแrio."
    lRet := .F.
   Else
    If cTpMarc == "HSPADM"
     If oObj:aCols[nMar, oObj:oBrowse:nColPos] == "LBNO" .And. oObj:aCols[nMar, nPosDev] == "LBTIK"
      Hs_MsgInf(STR0070, STR0002, STR0069)   //"Produto jแ foi devolvido."###"Aten็ใo"###"Valida็ใo marca็ใo de horแrio."
      lRet := .F.
     ElseIf (oObj:aCols[nMar, nPosLeg] == "BR_VERMELHO" .And. GNR->GNR_ADMINI == "1")
      Hs_MsgInf(STR0071, STR0002, STR0069) //"O produto jแ foi administrado."###"Aten็ใo"###"Valida็ใo marca็ใo de horแrio."
      lRet := .F.
     Endif
    Else
     If oObj:aCols[nMar, oObj:oBrowse:nColPos] == "LBNO" .And. oObj:aCols[nMar, nPosAdm] == "LBTIK"
      Hs_MsgInf(STR0072, STR0002, STR0069)   //"Produto jแ foi administrado."###"Aten็ใo"###"Valida็ใo marca็ใo de horแrio."
      lRet := .F.
     ElseIf (oObj:aCols[nMar, nPosLeg] == "BR_VERMELHO" .And. GNR->GNR_DEVOLV == "1") 
      Hs_MsgInf(STR0073, STR0002, STR0069) //"O produto jแ foi devolvido."###"Aten็ใo"###"Valida็ใo marca็ใo de horแrio."
      lRet := .F.
     ElseIf oObj:aCols[nMar, nPosLeg] == "BR_PRETO" .And. Empty(GNR->GNR_SEQDES)
      Hs_MsgInf(STR0074, STR0002, STR0069) //"O produto nใo foi atendido."###"Aten็ใo"###"Valida็ใo marca็ใo de horแrio."
      lRet := .F.
     Endif
    Endif
   Endif
     
   If lRet
    oObj:aCols[nMar, oObj:oBrowse:nColPos] := IIF(oObj:aCols[nMar, oObj:oBrowse:nColPos] == "LBNO", "LBTIK", "LBNO")
    nPos := aScan(aHorMarc, {|aVet| aVet[13] + aVet[1] +  aVet[2] == GNR->GNR_ITEPRE + oObj:aCols[nMar, nHorCdMedi] + oObj:aCols[nMar, nPosHor]})
   
     If oObj:aCols[nMar, oObj:oBrowse:nColPos] == "LBTIK"
      If nPos == 0   
       cSolici := HS_INIPADR("GHX", 1,GNR->GNR_ITEPRE + cRegate +  cSeqPre, "GHX_SOLICI",, .F.) 
       Aadd(aHorMarc,{oObj:aCols[nMar, nHorCdMedi], oObj:aCols[nMar, nPosHor], oObj:aCols[nMar, nPosDev], oObj:aCols[nMar, nPosAdm], "", GHX->GHX_QTDMED, 0, 0, GNR->GNR_SEQDES, cSolici, GHX->GHX_ITEGAJ, GHX->GHX_CDUNIC, GNR->GNR_ITEPRE, IIF(cTpMarc == "HSPDEV", .T., .F.)})
      Else
       aHorMarc[nPos, 3] := oObj:aCols[nMar, nPosDev]
       aHorMarc[nPos, 4] := oObj:aCols[nMar, nPosAdm]
      Endif
     Else
      aHorMarc[nPos, 3] := oObj:aCols[nMar, nPosDev]
      aHorMarc[nPos, 4] := oObj:aCols[nMar, nPosAdm]
     Endif
   Endif
  Endif
   
 Else 
  DbSeek(xFilial("GNR") + cRegate + cSeqPre + oObj:aCols[nMar, nHorItemBr] + oObj:aCols[nMar, nHorCdMedi])
  nPos := aScan(aHorMarc, {|aVet| aVet[13] + aVet[1] == oObj:aCols[nMar, nHorItemBr] + oObj:aCols[nMar, nHorCdMedi]})
  If nPos > 0 
   aHorMarc[nPos, 6] := GNR->GNR_QTDATE
   aHorMarc[nPos, 7] := GNR->GNR_QTDDEV
   FS_QtdAvul(oObj:aCols[nMar, nHorCdMedi], oObj:aCols[nMar, nHorItemBr]) 
  Endif
 Endif
  
 oObj:oBrowse:Refresh()   
 RestArea(aArea) 
Return(lRet)         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_ConAdmบ Autor ณ Mario Arizono      บ Data ณ  20/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravar produtos administrados.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ConAdm(oObj, cRegate, cSeqPre)

 Local lRet		:= .T.
 Local nPos		:= 0
 Local lMarc	:= .F.
 Local lGHVFim	:= .T.
 Local aGNRArea	:= {}
 Local aGHVArea	:= {}
  
 If !Empty(aHorMarc)
 
  DbSelectArea("GNR")
  DbSetOrder(2)
  
  For nPos := 1 to len(aHorMarc)
   If aHorMarc[nPos, 4] == "LBTIK" .Or. aHorMarc[nPos, 8] > 0
    DbSeek(xFilial("GNR") + cRegate + cSeqPre + aHorMarc[nPos, 13] + aHorMarc[nPos, 1] + aHorMarc[nPos, 2])
    
    RecLock("GNR", .F.)
     If aHorMarc[nPos, 4] == "LBTIK"
      GNR->GNR_ADMINI := "1"
     Else
      GNR->GNR_QTDADM := aHorMarc[nPos, 8]
     Endif
    MsUnlock()
   
    lMarc := .T.
   Endif
 
  Next nPos
 Else
  Hs_MsgInf(STR0075, STR0002, STR0056)  //"Nenhum item selecionado."###"Aten็ใo"###"Valida็ใo horแrios prescri็ใo."
  lRet := .F.
 Endif
 
 If lMarc
 
  //Verifica se todos os registros da GNR com o mesmo cRegate e cSeqPre estao administrados ou suspensos, para atualizar na GHV
  
  aGNRArea := GNR->(GetArea())
  GNR->(DbGoTop())

  If ! GNR->(DbSeek(xFilial("GNR") + cRegate + cSeqPre))
     lGHVFim := .F.
  EndIf

  While ! GNR->(Eof()) .And. GNR->GNR_REGATE + GNR->GNR_SEQPRE == cRegate + cSeqPre

	If GNR->GNR_ADMINI <> "1"
	     lGHVFim := .F.
	EndIf

	GNR->(DbSkip())
  
  EndDo

  If lGHVFim
  
  	aGHVArea := GHV->(GetArea())

  	If GHV->(DbSeek(xFilial("GHV") + cRegate + cSeqPre))

    	RecLock("GHV", .F.)
    	
      		If lGHVFim
      			GHV->GHV_STATUS := "2"
      		EndIf

    	MsUnlock()

	EndIf

  	RestArea(aGHVArea)
  
  EndIf
  
  RestArea(aGNRArea)
 
  Hs_MsgInf(STR0076, STR0002, STR0056)  //"Produto(s) administrado(s) com sucesso."###"Aten็ใo"###"Valida็ใo horแrios prescri็ใo."
 Endif
 
 
Return(lRet)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_QtdAvul Autor  ณ Mario Arizono      บ Data ณ  21/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para Mostrar itens avulsos.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_QtdAvul(cProdut, cItemBr)
 Local aArea := GetArea()
 Local lRet 			:= .F.
 Private oCodigo, oDesPro, oQtdIni, oQtdDev, oQtdAdm, oQtADev, oQtAAdm 
 Private cCodigo  := SPACE(LEN(GNR->GNR_PRODUT))
 Private cDesPro  := SPACE(LEN(SB1->B1_DESC)) 
 Private nQtdIni  := 0, nPos := 0, nOpcA := 0
 Private nQtdDev  := 0
 Private nQtdAdm  := 0
 Private nQtADev  := 0
 Private nQtAAdm  := 0
  
 nPos := aScan(aHorMarc, {|aVet| aVet[13] + aVet[1] == cItemBr + cProdut })
 
 If nPos == 0 .Or. !Empty(aHorMarc[nPos, 2])
 
  Return(Nil)
 Endif
 cCodigo := aHorMarc[nPos, 1]
 cDesPro := aHorMarc[nPos, 5]
 nQtdIni := aHorMarc[nPos, 6]
 nQtdDev := aHorMarc[nPos, 7]
 nQtdAdm := aHorMarc[nPos, 8]
    
 
	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )
 
 
 DEFINE MSDIALOG oDlgAvu TITLE STR0077 From 09, 00 to 25, 90 of oMainWnd //"Consulta Quantidade "
  
  oPanHor	:=	tPanel():New(aPObj[1, 1], aPObj[1, 2],,,,,,,, aPObj[1, 3], aPObj[1, 4])
  
 	@ 025, 022 Say STR0078 Of oPanHor Pixel COLOR CLR_BLUE  //"C๓digo"
	 @ 023, 045 MsGet oCodigo VAR cCodigo Picture "@!" WHEN .F. OF oPanHor Pixel
	 @ 023, 138 MsGet oDesPro VAR cDesPro WHEN .F. OF oPanHor Pixel  
 	@ 052, 010 Say STR0079 Of oPanHor Pixel COLOR CLR_BLUE  //"Qtd. Atendida"
	 @ 050, 045 MsGet oQtdIni VAR nQtdIni PICTURE "@E 999.999" WHEN .F. OF oPanHor Pixel
	 @ 052, 117 Say STR0080 Of oPanHor Pixel COLOR CLR_BLUE  //"Qtd. Devolvida"
  @ 050, 157 MsGet oQtdDev VAR nQtdDev PICTURE "@E 999.999" WHEN .F. OF oPanHor Pixel
  @ 052, 235 Say STR0081 Of oPanHor Pixel COLOR CLR_BLUE  //"Qtd. Administrada"
  @ 050, 281 MsGet oQtdAdm VAR nQtdAdm PICTURE "@E 999.999" WHEN .F. OF oPanHor Pixel
	 @ 079, 010 Say STR0082 Of oPanHor Pixel COLOR CLR_BLUE  //"Qtd. a Devolv."
  @ 077, 045 MsGet oQtADev VAR nQtADev VALID FS_VldQtd("DEV") PICTURE "@E 999.999" OF oPanHor Pixel
  @ 079, 117 Say STR0083 Of oPanHor Pixel COLOR CLR_BLUE  //"Qtd. a Administ."
  @ 077, 157 MsGet oQtAAdm VAR nQtAAdm VALID FS_VldQtd("ADM") PICTURE "@E 999.999" OF oPanHor Pixel


  	 
	ACTIVATE MSDIALOG oDlgAvu CENTERED ON INIT EnchoiceBar(oDlgAvu, 	{|| nOpcA := 1, oDlgAvu:End()}, ;
																																																																		{|| nOpcA := 0, oDlgAvu:End()})
	
	If nOpcA == 1     
	 If aHorMarc[nPos, 7] <> nQtdDev
   aHorMarc[nPos, 14] := .T.
  Endif
  aHorMarc[nPos, 7] := nQtdDev
  aHorMarc[nPos, 8] := nQtdAdm
	Endif
		
 RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldQtd  Autor  ณ Mario Arizono      บ Data ณ  26/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para Validar quantidades digitadas.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_VldQtd(cTipo)
Local lRet    := .T.
Local aArea   := GetArea()
Local nTotAtu := nQtdDev + nQtdAdm

 If (IIf(cTipo == "DEV", nQtAdev, nQtAAdm) + nTotAtu) > nQtdIni 
  HS_MsgInf(STR0084 + IIF(cTipo == 	"DEV", STR0085 , STR0086) + STR0087, STR0002, STR0088) //"Quantidade a "###"devolver"###"administrar"###" invแlida."###"Aten็ใo"###"Valida็ใo Quantidade."
  lRet := .F.
 Endif 
  
 If lRet
  If cTipo == "DEV"
   nQtdDev += nQtADev
   oQtdDev:Refresh()
   nQtADev := 0
   oQtADev:Refresh()
  Else
   nQtdAdm += nQtAAdm
   oQtdAdm:Refresh()    
   nQtAAdm := 0
   oQtAAdm:Refresh()
  Endif
 EndIf  
  
 RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GerDev  Autor  ณ Mario Arizono      บ Data ณ  26/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gerar devolucoes de acordo com os horarios.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_GERDEV(cRegate, cSeqPre, cCodLoc)
 Local nPos    := 0, nQtdDev := 0, nPosGd5 := 0, nContGd := 0
 Local nPosMarc:= 0, nItem := 0
 Local cAlmori := "", cSolici
 Local lInicio := .T.                   
 Local aArea   := GetArea()
 Local aRetDes := {}
 Local cNumDev := ""
 
 Begin Transaction
 
  If (nPos := aScan(aHorMarc, {|aVet| aVet[3] == "LBTIK" })) == 0
   nPos := aScan(aHorMarc, {|aVet| aVet[7] <> 0})
  Endif
   
  If nPos > 0   
  
   DbSelectArea("GCS")                                                                 
   DbSetOrder(1)
   DbSeek(xfilial("GCS")+cCodLoc)
   
   cAlmori := HS_ArmFarS(.T.) 
 
   aSort(aHorMarc,,,{|x,y| x[10] < y[10]})
  
   For nPosMarc := 1 to len(aHorMarc)
    
    If !aHorMarc[nPosMarc, 14]
     Loop
    Endif
    
    DbselectArea("GBD")
    DbSetOrder(1)                   
  
    If (cSolici <> aHorMarc[nPosMArc, 10] .And. !Empty(aHorMarc[nPosMArc, 10])) .Or. (Empty(aHorMarc[nPosMArc, 10]) .and. lInicio)
     M->GBD_NUMDEV := HS_VSxeNum("GBD", "M->GBD_NUMDEV", 1)
     
     If !Empty(aHorMarc[nPosMArc, 10])
      cNumDev := M->GBD_NUMDEV
     Endif
    
     ConfirmSx8()
        
     RecLock("GBD", .T.)
      GBD->GBD_FILIAL := xFilial("GBD")
      GBD->GBD_NUMDEV := M->GBD_NUMDEV
      GBD->GBD_REGATE := cRegate
      GBD->GBD_CODLOC := cCodLoc
	    	If Hs_ExisDic({{"C","GBD_ALMORI"}},.F.)
		     GBD->GBD_ALMORI := cAlmori
		    Endif
      GBD->GBD_DATDEV := dDataBase
      GBD->GBD_FLGDEV := IIf(Empty(aHorMarc[nPosMArc, 10]), "2", "0")
      GBD->GBD_LOGARQ := HS_LogArq()
     MsUnLock()
     lInicio := .F. 
     nItem   := 1                                  
    Endif
   
    DbSelectArea("GNR")
    DbSetOrder(2)
    DbSeek(xFilial("GNR") + cRegate + cSeqPre + aHorMarc[nPosMarc, 13] + aHorMarc[nPosMarc, 1] + aHorMarc[nPosMarc, 2])
    
    RecLock("GNR", .F.)
     If aHorMarc[nPosMarc, 3] == "LBTIK"
      GNR->GNR_DEVOLV := "1"
      nQtdDev := FS_DEVHOR(aHorMarc[nPosMarc, 1], aHorMarc[nPosMarc, 6], aHorMarc[nPosMarc, 12])
     Else
      nQtdDev := aHorMarc[nPosMarc, 7] - GNR->GNR_QTDDEV
      GNR->GNR_QTDDEV := aHorMarc[nPosMarc, 7]
     Endif
    MsUnlock()
    
    aHorMarc[nPosMarc, 14] := .F. 
    If !Empty(aHorMarc[nPosMArc, 10]) .And. aHorMarc[nPosMarc, 7] > 0
     aRetDes := FS_RetDes(aHorMarc[nPosMarc, 10], aHorMarc[nPosMarc, 11], nQtdDev)    
     nContGd := len(aRetDes)
    Else
     nContGd := 1
    Endif
      
    DbSelectArea("GBE")
    DbSetOrder(1)
    For nPosGd5 := 1 to nContGD
     RecLock("GBE", .T.)
      GBE->GBE_FILIAL := xFilial("GBE")
      GBE->GBE_NUMDEV := M->GBD_NUMDEV
      GBE->GBE_ITEDEV := StrZero(nItem++, Len(GBE->GBE_ITEDEV))
      GBE->GBE_SOLICI := aHorMarc[nPosMarc, 10]
      GBE->GBE_ITESOL := aHorMarc[nPosMarc, 11]
      GBE->GBE_DATSOL := dDatabase
      GBE->GBE_PRODEV := aHorMarc[nPosMarc, 1]
      GBE->GBE_QTDADV := If (!Empty(aRetDes), aRetDes[nPosGd5, 1],nQtdDev)
      GBE->GBE_QTDDEV := IIf(Empty(aHorMarc[nPosMarc, 10]), GBE->GBE_QTDADV , 0)
      GBE->GBE_SEQDES := If (!Empty(aRetDes), aRetDes[nPosGd5, 2], aHorMarc[nPosMarc, 9])
      GBE->GBE_LOGDEV := HS_LogArq()
      GBE->GBE_LOGARQ := HS_LogArq()
     MsUnlock()
          
     If Empty(aHorMarc[nPosMarc, 10])
      DbSelectArea("GD5")
      DbSetOrder(1)
      DbSeek(xFilial("GD5") + GBE->GBE_SEQDES)
      RecLock("GD5", .F., .F.)
      If (GBE->GBE_QTDDEV) == GD5->GD5_QTDDES
       DbDelete()
      Else
      GD5->GD5_QTDDES -= (GBE->GBE_QTDDEV)
	     EndIf
     Endif
    Next nPosGd5
    If !Empty(aRetDes)
     aRetDes := {}
    Endif 
    cSolici := aHorMarc[nPosMarc, 10]
  
   Next 
  Endif 
 End Transaction
 
 If !Empty(cNumDev)
  HSPAHR04(cNumDev, cCodLoc)
 Endif
 
 RestArea(aArea)
 
Return(Nil) 
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_QtdLan  Autor  ณ Mario Arizono      บ Data ณ  29/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para retornar quantidade enviada para farma/conta.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


Static Function FS_QtdLan(cRegate, cSeqPre, cAlmori, cFrqPri, cProdut, nQtde, dDatPre, cCdunic, nPos)
 Local aArea   := GetArea()
 Local nQtdRet := 0
 Local cGbiUni := "" 
  
 FS_TABHOR(cFrqPri, cAlmori, dDatPre, , @nQtdRet, cRegate, cSeqPre, nPos)
 
 
 cGbiUni :=  HS_IniPadr("GBI", 1, cProdut , "GBI_UNICON") 
 
 If HS_CountTB("GNS", "GNS_CODPRO  = '" + cProdut + "' AND GNS_UNPRES  = '" + cCdUnic + "' AND GNS_UNFATU  = '" + cGbiUni + "'")  > 0
  nQtdRet := IIF(nQtdRet == 0, 1, nQtdRet)
 Else
  nQtdRet := IIF(nQtdRet == 0, nQtde, nQtdRet * nQtde)
 Endif
  
 RestArea(aArea)
Return(nQtdRet)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DevHor  Autor  ณ Mario Arizono      บ Data ณ  29/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validar e retornar quantidade a devolver.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


Static Function FS_DevHor(cProdut, nQtde, cCdUnic)
 Local aArea   := GetArea()
 Local nQtdRet := 0
 Local cGbiUni := "" 
  
 cGbiUni :=  HS_IniPadr("GBI", 1, cProdut , "GBI_UNICON") 
 
 If HS_CountTB("GNS", "GNS_CODPRO  = '" + cProdut + "' AND GNS_UNPRES  = '" + cCdUnic + "' AND GNS_UNFATU  = '" + cGbiUni + "'")  > 0
  nQtdRet := 1
 Else
  nQtdRet := nQtde
 Endif
  
 RestArea(aArea)
Return(nQtdRet)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetLeg  Autor  ณ Mario Arizono      บ Data ณ  01/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para retornar cor de legenda correta.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


Static Function FS_RetLeg(aLegend, cCampo, cValor)
 Local cCorLeg := ""
             
 cCorLeg :=  aLegend[aScan(aLegend, {| aVet | aVet[1] == cCampo + " == '" + cValor + "'"  }),2]
 
Return(cCorLeg)
                               
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetDes  Autor  ณ Mario Arizono      บ Data ณ  02/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para retornar sequencial e quantidade despesa.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


Static Function FS_RetDes(cSolici, cItesol, nQtdDev)
 Local aRet  := {}
 Local aArea := GetArea()
  
 DbSelectArea("GD5")
 DbSetOrder(4)
 If Dbseek(xFilial("GD5") + cSolici + cIteSol)
  
  While (GD5->GD5_FILIAL == xFilial("GD5") .And. GD5->GD5_SOLICI == cSolici .And. GD5->GD5_ITESOL == cItesol)
   If nQtdDev > 0
    IF nQtdDev <= GD5->GD5_QTDDES
     nQtdDev := 0
    Else 
     nQtdDev -= GD5->GD5_QTDDES
    Endif
    
   	aAdd(aRet, {IIF(nQtdDev == 0, GD5->GD5_QTDDES, nQtdDev), GD5->GD5_SEQDES}) 
   
   Endif 
 
  DbSkip()
  End
 Endif
             
 RestArea(aArea) 
Return(aRet)
                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GrvGnr  Autor  ณ Mario Arizono      บ Data ณ  03/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravar horarios na GNR.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_GrvGnr(cSeqDes, cSolici, cIteGaj, cProdut, nQtde)
 Local aArea := GetArea()
 Local lFarm := .F. 
 Local nPresc := 0
   
 If HS_ExisDic({{"T", "GNR"}}, .F.) 
  If !Empty(cSolici)
   DbSelectArea("GHX")
   DbSetOrder(3)
   lFarm := DbSeek(xFilial("GHX")+ cSolici + cProdut + cIteGaj)
  Endif 
  DbSelectArea("GNR")
  DbSetOrder(IIF(lFarm, 1, 3))
  If DbSeek(xFilial("GNR") + IIF(lFarm, GHX->GHX_REGATE + GHX->GHX_SEQPRE + GHX->GHX_ITEMBR + GHX->GHX_CDMEDI, cSeqDes))
   While xFilial("GNR") == GNR->GNR_FILIAL .And. GNR->GNR_PRODUT == cProdut .And. nPresc < nQtde .And. IIF(!lFarm .Or. !Empty(GNR->GNR_HORPRE) , GNR->GNR_SEQDES == cSeqdes, .T.)
    
    RecLock("GNR", .F.)
     If !Empty(GNR->GNR_HORPRE) 
      If GNR->GNR_DEVOLV == "0" .And. GNR->GNR_ADMINI == "0" .And. GNR->GNR_STATUS $ "2/3" 
       GNR->GNR_DEVOLV := "1"
       nPresc++
      Endif
     Else                  
      If (GNR->GNR_QTDDEV + GNR->GNR_QTDADM) < GNR->GNR_QTDATE
       GNR->GNR_QTDDEV += nQtde
       nPresc++
      Endif
     Endif
    MsUnLock()
   
    
    DbSkip()
   End
  Endif
 Endif
              
 RestArea(aArea) 
Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CposGnr Autor  ณ Mario Arizono      บ Data ณ  03/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para atualizar  horarios.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_CposGnr()
 Local aArea := GetArea()
 Local nProd := 0, nItens := 0

 If Type("oGdHor") <> "U" 
  For nProd := 1 to len(oGDHor:aCols) 
   For nItens := 8 to len(oGdHor:aCols[nProd]) step 3
    If len(ALLTRIM(oGDHor:aCols[nProd, nItens])) > 1
      
     DbSelectArea("GNR")
     DbSetOrder(2)
     If DbSeek(xFilial("GNR") + cAtendi + cSequen + oGdHor:aCols[nProd, 1] + oGdHor:aCols[nProd, 2] + oGdHor:aCols[nProd, nItens])
      oGdHor:aCols[nProd, nItens - 1] :=  FS_RetLeg(aLegGnr, "GNR_STATUS", GNR->GNR_STATUS)
      oGdHor:aCols[nProd, nItens - 3] := IIF(GNR->GNR_DEVOLV == "1", "LBTIK", "LBNO")
     Endif
    Else
     exit
    Endif
    
   Next nItens
 
  Next nProd 
 
  oGdHor:Refresh()  
 Endif             
 RestArea(aArea) 
Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ConfCui Autor  ณ Mario Arizono      บ Data ณ  26/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para realizar observacao cuidado.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_ConfCui(cRegate)
 Local aArea := GetArea()
 Local lRet := .T.               
 Local cMntAtu := "", cMntIni := ""
 
 
 If Empty(oCuid:aCols[oCuid:oBrowse:nAt, nCuidProdu])
  HS_MsgInf(STR0104, STR0002, STR0107) //"Cuidado selecionado invแlido."###"Aten็ใo"###"Valida็ใo realiza็ใo do cuidado"
  lRet := .F.
 ElseIf Empty(cObserv) .Or. Empty(dDatExe) .Or. Empty(cHorExe)  
   HS_MsgInf(STR0108, STR0002, STR0107) //"Para a realiza็ใo do cuidado, os campos observa็ใo, data da execu็ใo e hora da execu็ใo terใo que estar preenchidos. Verifique."###"Aten็ใo"###"Valida็ใo realiza็ใo do cuidado"
   lRet := .F.
 Else 
  If (dDatExe < oCPres:aCols[oCPres:oBrowse:nAt, nGhvdatPre]) .Or. (dDatExe == oCPres:aCols[oCPres:oBrowse:nAt, nGhvdatPre] .And. cHorExe < oCPres:aCols[oCPres:oBrowse:nAt, nGhvHorCri])
   HS_MsgInf(STR0121, STR0002, STR0107) //"Realiza็ใo do cuidado nใo pode ser feita com data/hora anterior เ data de prescri็ใo."###"Aten็ใo"###"Valida็ใo realiza็ใo do cuidado"
   lRet := .F.
  Endif
 Endif 
 
 If lRet    
  
  cMntIni := STR0109+ DTOC(dDatExe) + " " + cHorExe + STR0110 + cUserName + STR0111 + cObserv //"- Realizado em "###" | Usuแrio: "###" | Observa็ใo : "
  cMntAtu  := ALLTRIM(oCuid:aCols[oCuid:oBrowse:nAt, nCuidProdu]) + " - " +  ALLTRIM(oCuid:aCols[oCuid:oBrowse:nAt, nCuidDesPr]) + chr(13)+ chr(10) 
 
  cMntAtu += cMntIni + chr(13)+ chr(10)
  
  If !Empty(cMemObs)
   cMemObs += chr(13) + chr(10) + cMntAtu 
  Else
   cMemObs := cMntAtu
  Endif
 
  DbSelectArea("GHX")
  DbSetOrder(1)                                                                   
  Dbseek(xFilial("GHX") + oCuid:aCols[oCuid:oBrowse:nAt, nCuidItem] + cRegate + oCPres:aCols[oCPres:oBrowse:nAt, nGhvSeqPre] )
 
  Begin Transaction
  
   RecLock("GHX", .F.)
    GHX->GHX_OBSCUI := cMemObs
   MsUnLock()
   
  End Transaction
  
  dDatExe := CTOD("  /  /  ")
  cHorExe := SPACE(5)     
  cObserv := SPACE(330)
  
  oObsRea:Refresh()
  oDatExe:Refresh()
  oHorExe:Refresh()
  oMemObs:Refresh()
 
 Endif
 
 RestArea(aArea) 
Return(lRet)     

                 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AtuCuid Autor  ณ Mario Arizono      บ Data ณ  27/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para atualizar memo cuidado.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_AtuCuid(cRegate)
 Local aArea := GetArea()
 
 
 If  !Empty(oCuid:aCols[oCuid:oBrowse:nAt, nCuidItem])
 
  DbSelectArea("GHX")
  DbSetOrder(1)                                                                   
  Dbseek(xFilial("GHX") + oCuid:aCols[oCuid:oBrowse:nAt, nCuidItem] + cRegate + oCPres:aCols[oCPres:oBrowse:nAt, nGhvSeqPre] )
    
	 cMemObs := GHX->GHX_OBSCUI
  
  oMemObs:Refresh()
 
  oObsRea:Enable()
  oDatExe:Enable()
  oHorExe:Enable() 
  oBtnRCui:Enable()
 
 Else 
  cMemObs := ""
  oMemObs:Refresh()
  
  oObsRea:Disable()
  oDatExe:Disable()
  oHorExe:Disable() 
  oBtnRCui:Disable()
 Endif 
  
 RestArea(aArea) 
Return()     
     
 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldClick Autor ณ Mario Arizono      บ Data ณ  02/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validar duplo click item prescricao aba cuidad. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_VldClick(cRegate, cCodLoc)  
 Local lRet := .T.
 Local cVldStr := "" 
 Local aArea := GetArea()
 Local lAchou := .T.

 IF !Empty(oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntCodCui])
   
  cVldStr := IIf(!Empty(oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntDatIni]), StrZero(nGntDatIni, 2)+ "/" + StrZero(nGntHorIni, 2)+ "/" ;
                        + StrZero(nGntDatFim, 2)+ "/" + StrZero(nGntHorFim, 2), StrZero(nGntQtdade, 2))
  If oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntSituac] <> "2"
   If !(StrZero(oGDGnt:oBrowse:nColPos, 2) $ cVldStr)
    If !Empty(oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntDatIni])
     Begin Transaction
     DbSelectArea("GNT")
     DbSetOrder(1)
     lAchou := DbSeek(xFilial("GNT") + cRegate + oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntSeqIte])
   
     oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntDatFim] := dDatabase
     oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntHorFim] := Time()
     oGDGnt:aCols[oGDGnt:oBrowse:nAt, nGntSituac] := "2"
     oGDGnt:oBrowse:Refresh()
  
     RecLock("GNT", !lAchou)
      HS_GRVCPO("GNT", oGDGnt:aCols, oGDGnt:aHeader, oGDGnt:oBrowse:nAt)
      GNT->GNT_FILIAL := xFilial("GNT")
     MsUnlock()
      
      FS_GrvGd6(cRegate, oGDGnt:oBrowse:nAt, cCodLoc)
     End Transaction
    Endif
   Endif
  Endif
 Endif

 RestArea(aArea)
Return(lRet)                
 
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVCONF  Autor ณ Mario Arizono      บ Data ณ  02/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para gravar Confirmacao                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_GrvConf(cRegate, cCodLoc)  
 Local aArea     := getArea()
 Local lRet      := .T.  
 Local nPos      := 0 
 Local lAchouGnt := .T. 
 
 Begin Transaction
               
  If Len(oGDGnt:aCols) == 1 .And.  (Empty(oGDGnt:aCols[1, nGntCodCui]) .Or. oGDGnt:aCols[1, nUGnt+1])
   HS_MsgInf(STR0112, STR0002, STR0105) //"Nenhum item pode ser confirmado."###"Valida็ใo cuidado"
   lRet := .F.
  Else
     
   For nPos := 1 to  Len(oGDGnt:aCols) 
    If oGDGnt:aCols[nPos, nGntStareg] <> "BR_VERDE" .And. oGDGnt:aCols[nPos, nGntSituac] <> "2" .And. !oGDGnt:aCols[1, nUGnt+1]
     oGDGnt:aCols[nPos, nGntSituac] := IIF(Empty(oGDGnt:aCols[nPos, nGntDatIni]) .Or. (!Empty(oGDGnt:aCols[nPos, nGntDatIni]) .And. !Empty(oGDGnt:aCols[nPos, nGntDatFim])) , "2", "1")
     oGDGnt:oBrowse:Refresh()
    
     DbSelectArea("GNT")
     DbSetOrder(1)   
     lAchouGnt := DbSeek(xFilial("GNT") + cRegate + oGDGnt:aCols[nPos, nGntSeqIte])
    
     RecLock("GNT", !lAchouGnt)
      HS_GRVCPO("GNT", oGDGnt:aCols, oGDGnt:aHeader, nPos)
      GNT->GNT_FILIAL := xFilial("GNT")
      GNT->GNT_REGATE := cRegate
     MsUnlock()
   
     If Empty(oGDGnt:aCols[nPos, nGntDatIni]) .Or. (!Empty(oGDGnt:aCols[nPos, nGntDatIni]) .And. !Empty(oGDGnt:aCols[nPos, nGntDatFim]))
      FS_GrvGd6(cRegate, nPos, cCodLoc)
     Endif
   
    Endif
   Next 
 
  Endif
 End Transaction
  
 RestArea(aArea)
Return()                
 
Static Function FS_GrvGd6(cRegate, nItens, cCodLoc)
 Local aArea    := GetArea()
 Local aRValTD  := {}
 Local cCodTax  := HS_IniPadr("GNP",1, oGdGnt:aCols[nItens, nGntCodCui],"GNP_CODDES",,.F.)
 
 If !Empty(cCodTax) 
  DbSelectArea("GCZ")
  DbSetOrder(9) // GCZ_FILIAL + GCZ_STATUS + GCZ_REGATE + GCZ_CODCON + GCZ_CODPLA            
  If DbSeek(xFilial("GCZ") + "0" + cRegate) // Procura primeira guia em aberto.
 
   DbSelectArea("GCY")
   DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
   DbSeek(xFilial("GCY") + cRegate)
 
   aRValTD := HS_RValTD(cCodTax, GCZ->GCZ_CODPLA, cCodLoc,, dDatabase)
    
   M->GD6_SEQDES := HS_VSxeNum("GD6", "M->GD6_SEQDES", 1)
   ConfirmSx8()
   
   DbSelectArea("GD6")
   DbSetOrder(1) // GD6_FILIAL + GD6_SEQDES
   RecLock("GD6", .T.)
    GD6->GD6_FILIAL := xFilial("GD6")
    GD6->GD6_CODLOC := cCodLoc
    GD6->GD6_DATDES := dDatabase
    GD6->GD6_HORDES := Time()
    GD6->GD6_QTDDES := oGdGnt:aCols[nItens, nGntQtdade]
    GD6->GD6_CODDES := cCodTax
    GD6->GD6_VALDES := aRValTD[2]
    GD6->GD6_PCUDES := aRValTD[3]
    GD6->GD6_GLODES := IIf(aRValTD[4][1], "2", "0")
    GD6->GD6_SEQDES := M->GD6_SEQDES
    GD6->GD6_NRSEQG := GCZ->GCZ_NRSEQG
    GD6->GD6_REGATE := cRegate
    GD6->GD6_FATPAR := aRValTD[4][2] 
    GD6->GD6_CODTXC := aRValTD[7]
    GD6->GD6_DESTXC := aRValTD[8]    
    GD6->GD6_TABELA := aRValTD[9]    
    GD6->GD6_LOGARQ := HS_LogArq()
   MsUnLock()
  Endif
 Endif
 RestArea(aArea)
Return(Nil)                 
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDSAI   Autor ณ Mario Arizono      บ Data ณ  03/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para validar saida de tela.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_VldSai(cRegate)  
 Local aArea     := getArea()
 Local lRet      := .T.  
 Local nPos      := 0 
 Local lAchouGnt := .T. 
 
 nPos :=  aScan(oGDGnt:aCols, {| aVet | !Empty(aVet[nGntCodCui]) .And. aVet[nGntSituac] == "0" .And. !aVet[nUGnt + 1]}) 
 
 If nPos > 0
  HS_MsgInf(STR0113, STR0002, STR0105) //"Verifique sub-aba 'prescri็ใo' na aba cuidados, pois, existe(m) cuidado(s) sem confirma็ใo."###"Valida็ใo cuidado"
  lRet := .F.
 ElseIf (aScan(oGDGnt:aCols, {| aVet | !Empty(aVet[nGntCodCui]) .And. aVet[nUGnt + 1]})) > 0 
  Begin Transaction
   DbSelectArea("GNT")
   DbSetOrder(1)
   For nPos := 1 to  Len(oGDGnt:aCols) 
    If oGDGnt:aCols[nPos, nUGnt+1]
     DbSeek(xFilial("GNT") + cRegate + oGDGnt:aCols[nPos, nGntSeqIte])
    	RecLock("GNT", .F.)
	   	 DbDelete()
  	 	MsUnlock()
  	 	WriteSx2("GNT")
    Endif
   Next 
  End Transaction
 Endif 
  
 RestArea(aArea)
Return(lRet)      
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CHMEVOL  Autor ณ Mario Arizono      บ Data ณ  03/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para chamar evolucao.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_CHMEVOL(cCodLoc, cQuarto, cLeito)
 Local aArea := GetArea()
 
 DbSelectArea("GAV")
 DbSetOrder(1)
 DbSeek(xFilial("GAV") + cCodLoc + cQuarto + cLeito)
                                 
 HS_TriM30("GAV",  GAV->(RecNo()), 4)          
 
 RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ConfDie Autor  ณ Mario Arizono      บ Data ณ  17/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para realizar observacao dieta.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_ConfDie(cRegate)
 Local aArea := GetArea()
 Local lRet := .T.               
 Local cMntAtu := "", cMntIni := ""
 
 
 If Empty(oDiet:aCols[oDiet:oBrowse:nAt, nDieProdut])
  HS_MsgInf(STR0114, STR0002, STR0115) //"Dieta selecionada invแlida."###"Aten็ใo"###"Valida็ใo realiza็ใo da dieta"
  lRet := .F.
 ElseIf Empty(cObsDie) .Or. Empty(dDatDie) .Or. Empty(cHorDie)  
  HS_MsgInf(STR0116, STR0002, STR0115) //"Para a realiza็ใo da dieta, os campos observa็ใo, data da execu็ใo e hora da execu็ใo terใo que estar preenchidos. Verifique."###"Aten็ใo"###"Valida็ใo realiza็ใo da dieta"
  lRet := .F.
 Else 
  If (dDatDie < oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvdatPre]) .Or. (dDatDie == oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvdatPre] .And. cHorDie < oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvHorCri])
   HS_MsgInf(STR0122, STR0002, STR0107) //"Realiza็ใo da dieta nใo pode ser feita com data/hora anterior เ data de prescri็ใo."###"Aten็ใo"###"Valida็ใo realiza็ใo do cuidado"
   lRet := .F.
  Endif
 Endif 
 
 If lRet    
  
  cMntIni := STR0109+ DTOC(dDatDie) + " " + cHorDie + STR0110 + cUserName + STR0111 + cObsDie //"- Realizado em "###" | Usuแrio: "###" | Observa็ใo : "
  cMntAtu  := ALLTRIM(oDiet:aCols[oDiet:oBrowse:nAt, nDieProdut]) + " - " +  ALLTRIM(oDiet:aCols[oDiet:oBrowse:nAt, nDieDesPro]) + chr(13)+ chr(10) 
 
  cMntAtu += cMntIni + chr(13)+ chr(10)
  
  If !Empty(cMemDie )
   cMemDie  += chr(10) + cMntAtu 
  Else
   cMemDie  := cMntAtu
  Endif
 
  DbSelectArea("GHX")
  DbSetOrder(1)                                                                   
  Dbseek(xFilial("GHX") + oDiet:aCols[oDiet:oBrowse:nAt, nDieItemBr] + cRegate + oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvSeqPre] )
 
 
  MSMM(,10,,cMemDie,1,,,"GHX","GHX_OBSDIE")
 
  dDatDie := CTOD("  /  /  ")
  cHorDie := SPACE(5)     
  cObsDie := SPACE(330)
   
  oObsDie:Refresh()
  oDatDie:Refresh()
  oHorDie:Refresh()
  oMemDie:Refresh()
 
 Endif
 
 RestArea(aArea) 
Return(lRet)     

                 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AtuDiet Autor  ณ Mario Arizono      บ Data ณ  17/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para atualizar memo dieta.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Fs_AtuDiet(cRegate)
 Local aArea := GetArea()
 
 
 If  !Empty(oDiet:aCols[oDiet:oBrowse:nAt, nDieItemBr])
 
  DbSelectArea("GHX")
  DbSetOrder(1)                                                                   
  Dbseek(xFilial("GHX") + oDiet:aCols[oDiet:oBrowse:nAt, nDieItemBr] + cRegate + oCDPres:aCols[oCDPres:oBrowse:nAt, nGhvSeqPre] )
    
	 cMemDie := E_MSMM(GHX->GHX_OBSDIE,10)
  
  oMemDie :Refresh()
 
  oObsDie:Enable()
  oDatDie:Enable() 
  oHorDie:Enable() 
  oMemDie:Enable()
 
 Else 
  cMemDie := ""
  oObsDie:Disable()
  oDatDie:Disable()
  oHorDie:Disable() 
  oMemDie:Disable()
  oMemDie:Refresh()
 Endif 
  
 RestArea(aArea) 
Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetHPad Autor  ณ Mario Arizono      บ Data ณ  30/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para retornar horario padrao.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_RetHPad(cAlmori)
Local cHorPad	:= ""
Local cSql		:= ""
Local aArea		:= GetArea()
Local cHorEdit	:= GetNewPar("MV_HOREDIT", "N")
Local nPosHCri	:= aScan(oGDGHV:aHeader, {|aVet| aVet[2] == "GHV_HORCRI"})

If cHorEdit == "S" .And. !Empty(oGDGHV:aCols[oGDGHV:nAt,3])
	cHorPad := oGDGHV:aCols[oGDGHV:nAt, nPosHCri]
Else
	cSql := " SELECT GCS.GCS_HORPAD HORPAD "
	cSql += "   FROM "+RetSqlName("GCS")+" GCS "
	cSql += "  WHERE GCS.GCS_FILIAL = '"+xFilial("GCS")+"' "
	cSql += "    AND GCS.GCS_ARMSET = '" + cAlmori + "' AND GCS.GCS_TIPLOC =  'A' "
	cSql += "    AND GCS.D_E_L_E_T_ <> '*' "
	
	cSql := ChangeQuery(cSql)
	TCQUERY cSQL NEW ALIAS "QRY"
	
	DbSelectArea("QRY")
	
	cHorPad := IIF(HS_VldHora(QRY->HORPAD, .F.), QRY->HORPAD, "")
EndIf

DbCloseArea()

RestArea(aArea)

Return(cHorPad)
