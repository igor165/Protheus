#INCLUDE "HSPAHA28.ch"
#INCLUDE "protheus.CH"
#INCLUDE "TopConn.ch"
#include "PLSMGER.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA28  บ Autor ณ Cibele Peria       บ Data ณ  05/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Procedimento                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHA28()

Private cCadastro := STR0001 //"Cadastro de Procedimento"
Private aRotina   := MenuDef()
Private aCpoGD    := {}

Private lSUS   := Upper(GetMv("MV_ATESUS")) == "S"
Private __cTpPic	:= ""	// Variavel utilizada para tirar a mascara do campo GAZ_CGCPRE

AjustaSX1()
AjustaSXB()

/* Seleciona somente os campos do Folder Dados Gerais */
DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO
DbGoTop()
DbSeek("GA7")
While !Eof() .And. SX3->X3_ARQUIVO == "GA7"
	If 	X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. (SX3->X3_FOLDER == "1" .Or. (lSUS .And. SX3->X3_FOLDER == "2") )
		aAdd(aCpoGD, SX3->X3_CAMPO)
	EndIf
	DbSkip()
EndDo

DbSelectArea("GA7")
mBrowse(06, 01, 22, 75, "GA7")

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A28    บ Autor ณ Cibele Peria       บ Data ณ  05/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Procedimento                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A28(cAlias, nReg, nOpc)

Local nGDOpc 	:= IIF(aRotina[nOpc, 4] == 3 .Or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local nOpcG  	:= aRotina[nOpc, 4]
Local nOpcA  	:= 0
Local aSize  	:= {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}, oFolGDs
local lCriDeReFa := SuperGetMV("MV_CRITDRF", NIL, .F.) //Verifica se ha critica por procedimento/dente/regiao/face
local cCpoCriDRF := ""

Private lExbCrit	:= SuperGetMV("MV_CRITCLI", NIL, .F.) //Verifica se Exibe o Folder Para Cadastro de Critica

Private aCGA8 := {}, aHGA8 := {}, nUGA8 := 0, nLGA8 := 0
Private aCGFA := {}, aHGFA := {}, nUGFA := 0, nLGFA := 0
Private aCGHD := {}, aHGHD := {}, nUGHD := 0, nLGHD := 0
Private aCGHF := {}, aHGHF := {}, nUGHF := 0, nLGHF := 0
Private aCGHG := {}, aHGHG := {}, nUGHG := 0, nLGHG := 0
Private aCGHH := {}, aHGHH := {}, nUGHH := 0, nLGHH := 0
Private aCGGH := {}, aHGGH := {}, nUGGH := 0, nLGGH := 0
Private aCGGR := {}, aHGGR := {}, nUGGR := 0, nLGGR := 0
Private aCGGU := {}, aHGGU := {}, nUGGU := 0, nLGGU := 0
Private aCGK0 := {}, aHGK0 := {}, nUGk0 := 0, nLGK0 := 0
Private aCGK1 := {}, aHGK1 := {}, nUGk1 := 0, nLGK1 := 0
Private aCGK2 := {}, aHGK2 := {}, nUGK2 := 0, nLGK2 := 0
Private aCGK3 := {}, aHGK3 := {}, nUGK3 := 0, nLGK3 := 0
Private aCGK4 := {}, aHGK4 := {}, nUGK4 := 0, nLGK4 := 0
Private aCGK5 := {}, aHGK5 := {}, nUGK5 := 0, nLGK5 := 0
Private aCGK6 := {}, aHGK6 := {}, nUGK6 := 0, nLGK6 := 0
Private aCGLF := {}, aHGLF := {}, nUGLF := 0, nLGLF := 0
Private aCGTL := {}, aHGTL := {}, nUGTL := 0, nLGTL := 0
Private nGa8TABPRO := 0, nGa8DESTPR := 0, nGa8CODPRT := 0, nGa8DATVIG := 0
Private nGfaItePro := 0, nGfaCodGrp := 0
Private nGHDCODCBO := 0, nGHFCDGATE := 0, nGHGCDTATE := 0, nGHHCODCID := 0, nGTLCODIGO:=0, nGTLCODDEN:=0, nGTLCODFAC:=0
Private nGGHCDITEM := 0, nGGHCDMODC := 0, nGGRCDQUES := 0, nGGRCDITEM := 0
Private nGGUSEQMOD := 0, nGGUMODELO := 0
Private nGK2CODHAB := 0, nGK2GRPHAB := 0, nGK3CDESPL := 0, nGK4CODHAB := 0, nGK5CODMOD := 0
Private nGK6CODINR := 0, nGLFCDPROP := 0
Private aTela := {}, aGets := {}
Private oGA7, oGA8, oGFA, oGHD, oGHF, oGHG, oGHH, oGGH, oGGR, oGGU, oGK0 , oGLF, oGTL

DbSelectArea("GA7")
RegToMemory("GA7", nOpcG == 3)

nLGA8 := HS_BDados("GA8", @aHGA8, @aCGA8, @nUGA8, 1, M->GA7_CODPRO, IIF(aRotina[nOpc, 4] # 3, "GA8->GA8_CODPRO == '" + M->GA7_CODPRO + "'", Nil),,,,, "GA8_CODPRO/GA8_DESPRO")
nGa8TABPRO := aScan(aHGA8, {| aVet | aVet[2] == "GA8_TABPRO"})
nGa8CODPRT := aScan(aHGA8, {| aVet | aVet[2] == "GA8_CODPRT"})
nGa8DESTPR := aScan(aHGA8, {| aVet | aVet[2] == "GA8_DESTPR"})
nGa8DATVIG := aScan(aHGA8, {| aVet | aVet[2] == "GA8_DATVIG"})

nLGFA := HS_BDados("GFA", @aHGFA, @aCGFA, @nUGFA, 1, M->GA7_CODPRO, IIF(aRotina[nOpc, 4] # 3, "GFA->GFA_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
nGfaItePro := aScan(aHGFA, {| aVet | aVet[2] == "GFA_ITEPRO"})
nGfaCodGrp := aScan(aHGFA, {| aVet | aVet[2] == "GFA_CODGRP"})

nLGGH := HS_BDados("GGH", @aHGGH, @aCGGH, @nUGGH, 1, , IIF(aRotina[nOpc, 4] # 3, "GGH->GGH_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
nGGHCDITEM := aScan(aHGGH, {| aVet | aVet[2] == "GGH_CDITEM"})
nGGHCDMODC := aScan(aHGGH, {| aVet | aVet[2] == "GGH_CDMODC"})

nLGGR := HS_BDados("GGR", @aHGGR, @aCGGR, @nUGGR, 1, , IIF(aRotina[nOpc, 4] # 3, "GGR->GGR_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
nGGRCDQUES := aScan(aHGGR, {| aVet | aVet[2] == "GGR_CDQUES"})
nGGRCDITEM := aScan(aHGGR, {| aVet | aVet[2] == "GGR_CDITEM"})

nLGGU := HS_BDados("GGU", @aHGGU, @aCGGU, @nUGGU, 1, , IIF(aRotina[nOpc, 4] # 3, "GGU->GGU_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
nGGUSEQMOD := aScan(aHGGU, {| aVet | aVet[2] == "GGU_SEQMOD"})
nGGUMODELO := aScan(aHGGU, {| aVet | aVet[2] == "GGU_MODELO"})

nLGHH := HS_BDados("GHH", @aHGHH, @aCGHH, @nUGHH, 1, ,IIF(aRotina[nOpc, 4] # 3,"GHH->GHH_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
nGHHCODCID := aScan(aHGHH, {| aVet | aVet[2] == "GHH_CODCID"})

If lExbCrit
	if !lCriDeReFa
		cCpoCriDRF := "GTL_CODDEN/GTL_DESDEN/GTL_CODFAC/GTL_DESFAC" //Campos de critica por procedimento/dente/regiao/face
	endif
	nLGTL := HS_BDados("GTL", @aHGTL, @aCGTL, @nUGTL, 1,M->GA7_CODPRO ,IIF(aRotina[nOpc, 4] # 3,"GTL->GTL_CODPRO == '" + M->GA7_CODPRO + "'", Nil),,,,,cCpoCriDRF)
	nGTLCODIGO := aScan(aHGTL, {| aVet | aVet[2] == "GTL_CODCRI"})
	if lCriDeReFa
		nGTLCODDEN := aScan(aHGTL, {| aVet | aVet[2] == "GTL_CODDEN"})
		nGTLCODFAC := aScan(aHGTL, {| aVet | aVet[2] == "GTL_CODFAC"})
	endif
Endif
If lSUS
	nLGHD := HS_BDados("GHD", @aHGHD, @aCGHD, @nUGHD, 1, , IIF(aRotina[nOpc, 4] # 3, "GHD->GHD_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGHDCODCBO := aScan(aHGHD, {| aVet | aVet[2] == "GHD_CODCBO"})

	nLGK0 := HS_BDados("GK0", @aHGK0, @aCGK0, @nUGK0, 1, , IIF(aRotina[nOpc, 4] # 3, "GK0->GK0_CDPROP == '" + M->GA7_CODPRO + "'", Nil))
	nGK0CODOPM := aScan(aHGK0, {| aVet | aVet[2] == "GK0_CODOPM"})

	nLGK1 := HS_BDados("GK1", @aHGK1, @aCGK1, @nUGK1, 1, , IIF(aRotina[nOpc, 4] # 3, "GK1->GK1_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGK1CODSER := aScan(aHGK1, {| aVet | aVet[2] == "GK1_CODSER"})
	nGK1CODCLA := aScan(aHGK1, {| aVet | aVet[2] == "GK1_CODCLA"})

	nLGK2 := HS_BDados("GK2", @aHGK2, @aCGK2, @nUGK2, 1, , IIF(aRotina[nOpc, 4] # 3, "GK2->GK2_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGK2CODHAB := aScan(aHGK2, {| aVet | aVet[2] == "GK2_CODHAB"})
	nGK2GRPHAB := aScan(aHGK2, {| aVet | aVet[2] == "GK2_GRPHAB"})

	nLGK3 := HS_BDados("GK3", @aHGK3, @aCGK3, @nUGK3, 1, , IIF(aRotina[nOpc, 4] # 3, "GK3->GK3_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGK3CDESPL := aScan(aHGK3, {| aVet | aVet[2] == "GK3_CDESPL"})

	nLGK4 := HS_BDados("GK4", @aHGK4, @aCGK4, @nUGK4, 1, , IIF(aRotina[nOpc, 4] # 3, "GK4->GK4_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGK4CODHAB := aScan(aHGK4, {| aVet | aVet[2] == "GK4_CODHAB"})

	nLGK5 := HS_BDados("GK5", @aHGK5, @aCGK5, @nUGK5, 1, , IIF(aRotina[nOpc, 4] # 3, "GK5->GK5_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGK5CODMOD := aScan(aHGK5, {| aVet | aVet[2] == "GK5_CODMOD"})

	nLGK6 := HS_BDados("GK6", @aHGK6, @aCGK6, @nUGK6, 1, , IIF(aRotina[nOpc, 4] # 3, "GK6->GK6_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGK6CODINR := aScan(aHGK6, {| aVet | aVet[2] == "GK6_CODINR"})

	nLGHF := HS_BDados("GHF", @aHGHF, @aCGHF, @nUGHF, 1, , IIF(aRotina[nOpc, 4] # 3,"GHF->GHF_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGHFCDGATE := aScan(aHGHF, {| aVet | aVet[2] == "GHF_CDGATE"})

	nLGHG := HS_BDados("GHG", @aHGHG, @aCGHG, @nUGHG, 1, , IIF(aRotina[nOpc, 4] # 3,"GHG->GHG_CODPRO == '" + M->GA7_CODPRO + "'", Nil))
	nGHGCDTATE := aScan(aHGHG, {| aVet | aVet[2] == "GHG_CDTATE"})

	nLGLF := HS_BDados("GLF", @aHGLF, @aCGLF, @nUGLF, 1, , IIF(aRotina[nOpc, 4] # 3,"GLF->GLF_CDPROC == '" + M->GA7_CODPRO + "'", Nil))
	nGLFCDPROP := aScan(aHGLF, {| aVet | aVet[2] == "GLF_CDPROP"})
EndIf

If aRotina[nOpc, 4] == 3 .Or. nLGFA == 0
	aCGfa[1, nGfaItePro] := Soma1(aCGfa[1, nGfaItePro], Len(aCGfa[1, nGfaItePro]))
EndIf

If Empty(aCGGH[1, nGGHCDITEM])
 aCGGH[1, nGGHCDITEM] := StrZero(1, Len(GGH->GGH_CDITEM))
EndIf

If Empty(aCGGR[1, nGGRCDITEM])
 aCGGR[1, nGGRCDITEM] := StrZero(1, Len(GGR->GGR_CDITEM))
EndIf

If Empty(aCGGU[1, nGGUSEQMOD])
	aCGGU[1, nGGUSEQMOD] := StrZero(1, Len(GGU->GGU_SEQMOD))
EndIf

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 050, .T., .T. } )
AAdd( aObjects, { 100, 050, .T., .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGDs := MsObjSize( aInfo, aObjects, .T. )

nOpcA := 0
If nOpc == 7 //C๓pia
 aCpoAlt :=  {"GA7_CODPRO"}
 M->GA7_CODSUS := GA7->GA7_CODPRO
EndIf
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel

oGA7 := MsMGet():New("GA7", nReg, nOpc,,,, IIF(lSUS, Nil, aCpoGD), aPObjs[1],,,,,, oDlg)
oGA7:oBox:Align := CONTROL_ALIGN_ALLCLIENT

/* Folder */
If !lExbCrit
	If lSUS
		@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0008, STR0009, STR0049, STR0050, STR0051, STR0048, STR0045, STR0058, STR0059, STR0060, STR0061, STR0062, STR0063, "&14-Inst. Registro SUS", STR0046, STR0047,STR0065  //"&1-Tabelas de Procedimentos"###"&2-Grupos de Equipamentos"###"&3-Modalidade Coleta"###"&4-Laudos"###"&5-Modelos Laudos"###"&6-CID"###"&7-C.B.O."###"&8-OPM SUS"###"&9-Serv.\Classifica็ใo SUS"###"&10-Habilita็ใo SUS"###"&11-Esp. Leito SUS"###"&12-Incremento SUS"###"&13-Mod. Atendimento SUS"###"&14-Inst. Registro SUS"###"&15-Grupo de Atendimento"###"&16-Tipo de Atendimento"###"&17-Compatibilidade"
	Else
		@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0008, STR0009, STR0049, STR0050, STR0051, STR0048                                     //"&1-Tabelas de Procedimentos"###"&2-Grupos de Equipamentos"###"&3-Modalidade Coleta"###"&4-Laudos"###"&5-Modelos Laudos"
	EndIf
Else
	If lSUS
		@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0008, STR0009, STR0049, STR0050, STR0051, STR0048, STR0045, STR0058, STR0059, STR0060, STR0061, STR0062, STR0063, "&14-Inst. Registro SUS", STR0046, STR0047,STR0065,STR0075  //"&1-Tabelas de Procedimentos"###"&2-Grupos de Equipamentos"###"&3-Modalidade Coleta"###"&4-Laudos"###"&5-Modelos Laudos"###"&6-CID"###"&7-C.B.O."###"&8-OPM SUS"###"&9-Serv.\Classifica็ใo SUS"###"&10-Habilita็ใo SUS"###"&11-Esp. Leito SUS"###"&12-Incremento SUS"###"&13-Mod. Atendimento SUS"###"&14-Inst. Registro SUS"###"&15-Grupo de Atendimento"###"&16-Tipo de Atendimento"###"&17-Compatibilidade" ### "Crํticas"
	Else
		@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0008, STR0009, STR0049, STR0050, STR0051, STR0048,STR0075                                     //"&1-Tabelas de Procedimentos"###"&2-Grupos de Equipamentos"###"&3-Modalidade Coleta"###"&4-Laudos"###"&5-Modelos Laudos" ### "Criticas"
	EndIf
EndIf

oFolGDs:Align := CONTROL_ALIGN_BOTTOM

oGA8 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[1], aHGA8, aCGA8)
oGA8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGA8:cFieldOk := "HS_VldA28()"

oGFA := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,, "+GFA_ITEPRO",,,,,,, oFolGDs:aDialogs[2], aHGFA, aCGFA)
oGFA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGFA:cFieldOk := "HS_VldA28()"

oGGH := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGGH:oBrowse:nAt, oGGH:aCols, {nGGHCDMODC})",, "+GGH_CDITEM",,,,,,, oFolGDs:aDialogs[3], aHGGH, aCGGH)
oGGH:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGGR := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGGR:oBrowse:nAt, oGGR:aCols, {nGGRCDQUES})",, "+GGR_CDITEM",,,,,,, oFolGDs:aDialogs[4], aHGGR, aCGGR)
oGGR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGGU := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, ,, "+GGU_SEQMOD",,,,,,, oFolGDs:aDialogs[5], aHGGU, aCGGU)
oGGU:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

/* CID */
oGHH := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGHH:oBrowse:nAt, oGHH:aCols, {nGHHCODCID})",,,,,,,,, oFolGDs:aDialogs[6], aHGHH, aCGHH)
oGHH:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If lExbCrit
	/* Critica */
	oGTL := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGTL:oBrowse:nAt, oGTL:aCols, {nGTLCODIGO})",,,,,,,,, oFolGDs:aDialogs[IIF(lSUS, 18,7)], aHGTL, aCGTL)
	oGTL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif

If lSUS

		/* C.B.O */
	oGHD := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGHD:oBrowse:nAt, oGHD:aCols, {nGHDCODCBO})",,,,,,,,, oFolGDs:aDialogs[7], aHGHD, aCGHD)
	oGHD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/*OPM*/
	oGK0 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK0:oBrowse:nAt, oGK0:aCols, {nGK0CODOPM})",,,,,,,,, oFolGDs:aDialogs[8], aHGK0, aCGK0)
	oGK0:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Servi็o\Classifica็ใo */
	oGK1 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK1:oBrowse:nAt, oGK1:aCols, {nGK1CODSRV, nGK1CODCLA})",,,,,,,,, oFolGDs:aDialogs[9], aHGK1, aCGK1)
	oGK1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Habilita็ใo */
	oGK2 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK2:oBrowse:nAt, oGK2:aCols, {nGK2CODHAB, nGK2GRPHAB})",,,,,,,,, oFolGDs:aDialogs[10], aHGK2, aCGK2)
	oGK2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Especialidade do Leito */
	oGK3 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK3:oBrowse:nAt, oGK3:aCols, {nGK3CDESPL})",,,,,,,,, oFolGDs:aDialogs[11], aHGK3, aCGK3)
	oGK3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Incremento */
	oGK4 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK4:oBrowse:nAt, oGK4:aCols, {nGK4CODHAB})",,,,,,,,, oFolGDs:aDialogs[12], aHGK4, aCGK4)
	oGK4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Modalidade */
	oGK5 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK5:oBrowse:nAt, oGK5:aCols, {nGK5CODMOD})",,,,,,,,, oFolGDs:aDialogs[13], aHGK5, aCGK5)
	oGK5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Instrumento de Registro */
	oGK6 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGK6:oBrowse:nAt, oGK6:aCols, {nGK6CODREG})",,,,,,,,, oFolGDs:aDialogs[14], aHGK6, aCGK6)
	oGK6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	/* Grupo de Atendimento */
	oGHF := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGHF:oBrowse:nAt, oGHF:aCols, {nGHFCDGATE})",,,,,,,,, oFolGDs:aDialogs[15], aHGHF, aCGHF)
	oGHF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	/* Tipo de Atendimento */
	oGHG := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGHG:oBrowse:nAt, oGHG:aCols, {nGHGCDTATE})",,,,,,,,, oFolGDs:aDialogs[16], aHGHG, aCGHG)
	oGHG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 	/* Compatibilidade */
	oGLF := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0, "HS_DuplAC(oGLF:oBrowse:nAt, oGLF:aCols, {nGLFCDPROP})",,,,,,,,, oFolGDs:aDialogs[17], aHGLF, aCGLF)
	oGLF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. HS_TudoOK("GFA", oGFA, nGfaCodGrp) .and. oGA8:TudoOk() .And. IIF(nOpcG == 5, HS_DelOK(nOpcG), .T.) .And. HS_A28Idad() .and. fs_vldGTL(), oDlg:End(), nOpcA := 0)}, ;
                                                 {|| nOpcA := 0, oDlg:End()} )

If nOpcA == 1
	FS_GrvA28(IIf(nOpc == 7, 3, nOpcG))
EndIf

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDA28 บ Autor ณ Cibele Peria       บ Data ณ  05/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento a validacao para a getdados.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldA28()

Local lRet := .T., nPosACols := 0
Local cCampo := ReadVar()

If cCampo == "M->GA8_TABPRO"
	If ((nPosACols := aScan(oGa8:aCols, {| aVet | aVet[nGa8TabPro] == M->GA8_TABPRO .And. aVet[nGa8DatVig] == oGa8:aCols[oGa8:nAt, nGa8DatVig]})) > 0) .And. (nPosACols <> oGA8:nAt)
		HS_MsgInf(STR0010, STR0012, STR0013) //"Informa็ใo jแ cadastrada."###"Aten็ใo"###"Valida็ใo de campos"
		lRet := .F.
	EndIf
ElseIf cCampo == "M->GA8_DATVIG"
	If ((nPosACols := aScan(oGa8:aCols, {| aVet | aVet[nGa8TabPro] == oGa8:aCols[oGa8:nAt, nGa8TabPro] .And. aVet[nGa8DatVig] == M->GA8_DATVIG})) > 0) .And. (nPosACols <> oGA8:nAt)
		HS_MsgInf(STR0010, STR0012, STR0013) //"Informa็ใo jแ cadastrada."###"Aten็ใo"###"Valida็ใo de campos"
		lRet := .F.
	EndIf
ElseIf cCampo == "M->GFA_CODGRP"
	If ((nPosACols := aScan(oGfa:aCols, {| aVet | aVet[nGfaCodGrp] == M->GFA_CODGRP})) > 0) .And. (nPosACols <> oGFA:nAt)
		HS_MsgInf(STR0010, STR0012, STR0013) //"Informa็ใo jแ cadastrada."###"Aten็ใo"###"Valida็ใo de campos"
		lRet := .F.
	EndIf
ElseIf cCampo == "M->GP0_CODCON"
	If !(lRet := HS_SeekRet("GA9","M->GP0_CODCON", 1, .F., "GP0_NOMCON", "GA9_NOME"))
		HS_MsgInf(STR0037, STR0012, STR0013) //"Conv๊nio nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos"
	Else
		cCodCon := M->GP0_CODCON
	EndIf
ElseIf cCampo == "M->GP5_CODMED"
	If !(lRet := HS_SeekRet("SB1", "M->GP5_CODMED", 1, .F., "GP5_DESMED", "B1_DESC"))
		HS_MsgInf(STR0011, STR0012, STR0013)  //"Medicamento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos"
	ElseIf !(lRet := HS_SeekRet("GBI", "M->GP5_CODMED", 1, .F.))
		HS_MsgInf(STR0011, STR0012, STR0013)  //"Medicamento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos"
	ElseIf !(lRet := GBI->GBI_TIPO == "1")
		HS_MsgInf(STR0014 + AllTrim(GBI->GBI_PRODUT) + STR0015, STR0012, STR0013) //"Tipo do produto ["###"] nใo permitido"###"Aten็ใo"###"Valida็ใo de campos"
	EndIf

ElseIf cCampo == "M->GP7_CODMAT"
	If !(lRet := HS_SeekRet("SB1", "M->GP7_CODMAT", 1, .F., "GP7_DESMAT", "B1_DESC"))
		HS_MsgInf(STR0016, STR0012, STR0013)  //"Material nใo encontrado no cadastro de Produtos."###"Aten็ใo"###"Valida็ใo de campos"
	ElseIf !(lRet := HS_SeekRet("GBI", "M->GP7_CODMAT", 1, .F.))
		HS_MsgInf(STR0016, STR0012, STR0013)  //"Material nใo encontrado no cadastro de Produtos."###"Aten็ใo"###"Valida็ใo de campos"
	ElseIf !(lRet := GBI->GBI_TIPO == "0")
		HS_MsgInf(STR0014 + AllTrim(GBI->GBI_PRODUT) + STR0015, STR0012, STR0013) //"Tipo do produto ["###"] nใo permitido"###"Aten็ใo"###"Valida็ใo de campos"
	EndIf

ElseIf cCampo == "M->GGR_CDQUES"
	If !(lRet := HS_SeekRet("GFS", "M->GGR_CDQUES", 1, .F., "GGR_DSQUES", "GFS_DSQUES"))
	 HS_MsgInf(STR0052,STR0012,STR0013)
	EndIf

ElseIf cCampo == "M->GGR_CODCRM"
 If !(lRet := HS_SeekRet("SRA", "M->GGR_CODCRM", 11, .F., "GGR_NOMCRM", "RA_NOME"))
	 HS_MsgInf(STR0053,STR0012,STR0013)
	EndIf
ElseIf cCampo == "M->GGU_CODCRM"
 If !(lRet := HS_SeekRet("SRA", "M->GGU_CODCRM", 11, .F., "GGU_NOMCRM", "RA_NOME"))
	 HS_MsgInf(STR0054,STR0012,STR0013)
	EndIf
ElseIf cCampo == "M->GGR_CODPRO"
 If !(lRet := HS_SeekRet("GA7", "M->GGR_CODPRO", 1, .F., "GGR_DESPRO", "GA7_DESC"))
  HS_MsgInf(STR0055,STR0012,STR0013)
 EndIf

ElseIf cCampo == "M->GA7_CITISS" .AND. !EMPTY(M->GA7_CITISS)
 If !(lRet := HS_SeekRet("G20", "M->GA7_CITISS", 1, .F., "GA7_DCITIS", "G20_DESCRI"))
  HS_MsgInf(STR0056, STR0012, STR0057) //"Classifica็ใo de Itens nใo cadastrada."###"Aten็ใo"###"Valida็ใo dos Campos"
 EndIf
ElseIf !Empty(M->GA7_CODSUS )

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DelOK  บ Autor ณ Cibele Peria       บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica, no caso de exclusao, se o procedimento pode ser  บฑฑ
ฑฑบ          ณ excluido.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DelOK(nOpcG)

Local lRet  := .T.
Local aVet  := {"GA7", "GHD", "GHF", "GHG", "GHH"}
Local nCont := 0

If nOpcG <> 5     //Exclusao
	Return(lRet)
EndIf

For nCont := 1 To Len(aVet)

	If lSUS
		DbSelectArea("GD7")
		DbSetOrder(6) // GD7_FILIAL + GD7_CODDES
		If DbSeek(xFilial("GD7") + &(aVet[nCont]+ "->" + aVet[nCont] + "_CODPRO"))
			lRet := .F.
		Else
			DbSelectArea("GE7")
			DbSetOrder(8) // GE7_FILIAL + GE7_CODDES
			If DbSeek(xFilial("GE7") + &(aVet[nCont] + "->" + aVet[nCont] + "_CODPRO"))
				lRet := .F.
			EndIf
		EndIf
	Else
		DbSelectArea("GD7")
		DbSetOrder(6) // GD7_FILIAL + GD7_CODDES
		If DbSeek(xFilial("GD7") + GA7->GA7_CODPRO)
			lRet := .F.
		Else
			DbSelectArea("GE7")
			DbSetOrder(8) // GE7_FILIAL + GE7_CODDES
			If DbSeek(xFilial("GE7") + GA7->GA7_CODPRO)
				lRet := .F.
			EndIf
		EndIf
	EndIf

Next nCont

If !lRet
	HS_MsgInf(STR0007, STR0012, STR0017) //"Este procedimento estแ sendo utilizado no Faturamento. Exclusใo nใo permitida"###"Aten็ใo"###"Valida็ใo para exclusใo"
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA28 บ Autor ณ Cibele Peria       บ Data ณ  05/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualizacao do cadastro                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvA28(nOpcG)

Local lAchou      := .T.
Local cGa7_TabPro := "", cUpdGBY := "", cAliasOld := ""
Local nForI       := 0
Local cCodSb1		:= ""
Local cDesSb1		:= ""
Local nPreco		:= 0

If nOpcG == 2     // Se for uma consulta
	Return(.T.)
EndIf

DbselectArea("GA7")
DbsetOrder(1) // GA7_FILIAL + GA7_CODPRO
lAchou := DbSeek(xFilial("GA7") + M->GA7_CODPRO)

Begin Transaction

If nOpcG == 3 .Or. nOpcG == 4   // INCLUSAO ou ALTERACAO

	//Se mudou a descricao alterar as solicitacoes de laudo
	If M->GA7_DESC <> GA7->GA7_DESC

	 cAliasOld := Alias()
	 DbSelectArea("SX3")
	 DbSetOrder(2)
	 If DbSeek("GBY_DESPRO") .And. SX3->X3_CONTEXT == "R"

 	 DbSelectArea("GBY")
	  cUpdGBY := "UPDATE " + RetSqlName("GBY") + " SET GBY_DESPRO = '" + M->GA7_DESC + "' "
	  cUpdGBY += "WHERE GBY_FILIAL = '" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*' AND "
	  cUpdGBY +=       "GBY_PROSOL = '" + M->GA7_CODPRO + "'"

	  TcSqlExec(cUpdGBY)
	 EndIf
	 DbSelectArea(cAliasOld)
	EndIf

	RecLock("GA7", !lAchou)
	HS_GRVCPO("GA7")
	GA7->GA7_FILIAL := xFilial("GA7")
	GA7->GA7_LOGARQ := HS_LOGARQ()
	MsUnlock()

Else                             // EXCLUSAO
	RecLock("GA7", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("GA7")
EndIf

//Gravacao das tabelas do procedimento
aCGA8 := aClone(oGA8:aCols)
cGa7_TabPro := ""
DbselectArea("GA8")
DbSetOrder(1) // GA8_FILIAL + GA8_CODPRO + GA8_TABPRO + GA8_DATVIG
For nForI := 1 To Len(aCGA8)
	DbselectArea("GA8")
	DbSetOrder(1) // GA8_FILIAL + GA8_CODPRO + GA8_TABPRO + GA8_DATVIG
	lAchou := DbSeek(xFilial("GA8") + M->GA7_CODPRO + aCGA8[nForI, nGa8TABPRO] + DTOS(aCGA8[nForI, nGa8DATVIG]))
	If nOpcG == 3 .Or. nOpcG == 4 //Inclusao ou alteracao
		If aCGA8[nForI, nUGA8 + 1] .And. lAchou // Exclusao
			RecLock("GA8", .F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2("GA8")
			MsUnLock()
		ElseIf !aCGA8[nForI, nUGA8 + 1]
			RecLock("GA8", !lAchou)
			HS_GRVCPO("GA8", aCGA8, aHGA8, nForI)
			GA8->GA8_FILIAL := xFilial("GA8")
			GA8->GA8_CODPRO := M->GA7_CODPRO
			GA8->GA8_LOGARQ := HS_LogArq()
			MsUnlock()
		EndIf
		cGa7_TabPro := cGa7_TabPro + IIF(!Empty(AllTrim(cGa7_TabPro)), "/", "") + GA8->GA8_TABPRO
	Else
		If lAchou            // opcao exclusao do menu
			RecLock("GA8", .F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2("GA8")
		EndIf
	EndIf
Next nForI


DbSelectArea("GA7")
RecLock("GA7", .F.)
GA7->GA7_TABPRO := cGa7_TabPro + "/"
MsUnLock()

//Gravacao dos Grupos de equipamentos do procedimento
FS_GrvGD("GFA", 1, oGFA:aCols, aHGFA, nUGFA, nGfaItePro, nGfaCodGrp, nOpcG)

//Gravacao dos Tipos  de Amostras
FS_GrvGD("GGH", 1, oGGH:aCols, aHGGH, nUGGH, nGGHCDITEM, nGGHCDMODC, nOpcG)

FS_GrvGD("GGR", 1, oGGR:aCols, aHGGR, nUGGR, nGGRCDITEM, nGGRCDQUES, nOpcG)

FS_GrvGD("GGU", 1, oGGU:aCols, aHGGU, nUGGU, nGGUSEQMOD, nGGUMODELO, nOpcG)


If lExbCrit
	FS_GrvGD("GTL", 1, oGTL:aCols, aHGTL, nUGTL, nGTLCODIGO, nGTLCODIGO, nOpcG)
Endif


If lSUS
 FS_GrvGD("GHF", 1, oGHF:aCols, aHGHF, nUGHF, nGHFCDGATE, nGHFCDGATE, nOpcG)
 FS_GrvGD("GHG", 1, oGHG:aCols, aHGHG, nUGHG, nGHGCDTATE, nGHGCDTATE, nOpcG)
 FS_GrvGD("GHH", 1, oGHH:aCols, aHGHH, nUGHH, nGHHCODCID, nGHHCODCID, nOpcG)
 FS_GrvGD("GHD", 1, oGHD:aCols, aHGHD, nUGHD, nGHDCODCBO, nGHDCODCBO, nOpcG)
 FS_GrvGD("GK0", 1, oGK0:aCols, aHGK0, nUGK0, nGK0CODOPM, nGK0CODOPM, nOpcG)
 FS_GrvGD("GK1", 1, oGK1:aCols, aHGK1, nUGK1, nGK1CODSER, nGK1CODSER, nOpcG)
 FS_GrvGD("GK2", 1, oGK2:aCols, aHGK2, nUGK2, nGK2CODHAB, nGK2CODHAB, nOpcG)
 FS_GrvGD("GK3", 1, oGK3:aCols, aHGK3, nUGK3, nGK3CDESPL, nGK3CDESPL, nOpcG)
 FS_GrvGD("GK4", 1, oGK4:aCols, aHGK4, nUGK4, nGK4CODHAB, nGK4CODHAB, nOpcG)
 FS_GrvGD("GK5", 1, oGK5:aCols, aHGK5, nUGK5, nGK5CODMOD, nGK5CODMOD, nOpcG)
 FS_GrvGD("GK6", 1, oGK6:aCols, aHGK6, nUGK6, nGK6CODINR, nGK6CODINR, nOpcG)
 FS_GrvGD("GLF", 1, oGLF:aCols, aHGLF, nUGLF, nGLFCDPROP, nGLFCDPROP, nOpcG)
EndIf

End Transaction

//**********************************************************************************
// INSERE PRODUTO NA SB1 - CADASTRO DE PRODUTO DO MำDULO DE ESTOQUE                *
//**********************************************************************************
If (nOpcG == 3 .Or. nOpcG == 4) .AND. HS_ExisDic({{"C", "GA7_VINSB1"}},.F.)
	If M->GA7_VINSB1 == "1" // Caso possua vinculo com a SB1
		cTipProd := SuperGetMV("MV_TPPRSB1", NIL, "PA")
		cCodSb1 := PADR(M->GA7_CODPRO, TAMSX3("B1_COD")[1])
		cDesSb1 := PADR(M->GA7_DESC, TAMSX3("B1_DESC")[1])
		If nOpcG == 3
			RecLock("SB1", .T.)
			SB1->B1_FILIAL := xFilial("SB1")
			SB1->B1_COD := cCodSb1
			SB1->B1_DESC := cDesSb1
			SB1->B1_TIPO := cTipProd
			SB1->B1_UM	 := "UN"
			SB1->B1_LOCPAD := "01"
			SB1->B1_PRV1 := FS_RETPRC(M->GA7_CODPRO)
			MsUnlock()

			RecLock("SB0", .T.)
			SB0->B0_FILIAL := xFilial("SB0")
			SB0->B0_COD := cCodSb1
			SB0->B0_PRV1 := FS_RETPRC(M->GA7_CODPRO)
			MsUnlock()
			If ExistBlock("HSA28B1")
				ExecBlock("HSA28B1", .F., .F., {M->GA7_CODPRO})
			EndIf
		Else
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek(xFilial("SB1") + cCodSb1)
				RecLock("SB1", .T.)
				SB1->B1_FILIAL := xFilial("SB1")
				SB1->B1_COD := cCodSb1
				SB1->B1_DESC := cDesSb1
				SB1->B1_TIPO := "PA"
				SB1->B1_UM	 := "UN"
				SB1->B1_LOCPAD := "01"
				SB1->B1_PRV1 := FS_RETPRC(M->GA7_CODPRO)
				MsUnlock()
				DbSelectArea("SB0")
				DbSetOrder(1)
				If !DbSeek(xFilial("SB0") + cCodSb1)
					RecLock("SB0", .T.)
					SB0->B0_FILIAL := xFilial("SB0")
					SB0->B0_COD := cCodSb1
					SB0->B0_PRV1 := FS_RETPRC(M->GA7_CODPRO)
					MsUnlock()
				Else
					RecLock("SB0", .F.)
						SB0->B0_PRV1 := FS_RETPRC(M->GA7_CODPRO)
					MsUnlock()
				EndIf
				If ExistBlock("HSA28B1")
					ExecBlock("HSA28B1", .F., .F., {M->GA7_CODPRO})
				EndIf
			Else
				nPreco := FS_RETPRC(M->GA7_CODPRO)
				If SB1->B1_PRV1 <> nPreco
					RecLock("SB1", .F.)
						SB1->B1_PRV1 := nPreco
					MsUnlock()
					DbSelectArea("SB0")
					DbSetOrder(1)
					If DbSeek(xFilial("SB0") + cCodSb1)
						RecLock("SB0", .F.)
						SB0->B0_PRV1 := nPreco
						MsUnlock()
					EndIf
				EndIf
				DbSelectArea("SB0")
				DbSetOrder(1)
				If !DbSeek(xFilial("SB0") + cCodSb1)
					RecLock("SB0", .T.)
					SB0->B0_FILIAL := xFilial("SB0")
					SB0->B0_COD := cCodSb1
					SB0->B0_PRV1 := nPreco
					MsUnlock()
				EndIf
			EndIf
		EndIf
	EndIf
EndIf


Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGD  บAutor  ณLuiz Pereira S. Jr. บ Data ณ  08/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada para gravar os dados referentes ao SUS     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GrvGD(cAlias, cOrder, aCols, aHead, nUsado, nCodItem, nChaveArq, nOpcG)

Local nForI  := 0
Local lAchou := 0
Local cPGrv :=  cAlias + "->" + PrefixoCpo(cAlias)

DbselectArea(cAlias)
DbSetOrder(1)
For nForI := 1 To Len(aCols)
	DbselectArea(cAlias)
	DbSetOrder(cOrder)
	lAchou := DbSeek(xFilial(cAlias) + M->GA7_CODPRO + aCols[nForI ,nCodItem])
	If nOpcG == 3 .Or. nOpcG == 4           //Inclusao ou alteracao
		If aCols[nForI, nUsado + 1] .And. lAchou  // Exclusao
			RecLock(cAlias, .F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
			MsUnLock()
		ElseIf !aCols[nForI, nUsado + 1] .And. !Empty(aCols[nForI, nChaveArq])
			RecLock(cAlias, !lAchou)
			HS_GRVCPO(cAlias, aCols, aHead, nForI)
			&(cPGrv + "_FILIAL") := xFilial(cAlias)
			&(cPGrv + "_CODPRO") := M->GA7_CODPRO
			MsUnlock()
		EndIf
	Else
		If lAchou            // opcao exclusao do menu
			RecLock(cAlias, .F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		EndIf
	EndIf
Next nForI

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A28Idadบ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao dos campos Idade Minima e Idade Maxima.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A28Idad()

Local cVar := ReadVar()
Local lRet := .T.

If cVar == "M->GA7_IDAMIN"
	If M->GA7_IDAMAX > 0
		If (M->GA7_IDAMAX<M->GA7_IDAMIN)
			HS_MsgInf(STR0039, STR0012, STR0040) //"A idade mแxima deve ser maior que a idade mํnima."###"Aten็ใo"###"Valida็ใo de Idade"
			lRet := .F.
		EndIf
	EndIf
ElseIf cVar == "M->GA7_IDAMAX"
	If (M->GA7_IDAMAX<M->GA7_IDAMIN)
		HS_MsgInf(STR0039, STR0012, STR0040) //"A idade mแxima deve ser maior que a idade mํnima."###"Aten็ใo"###"Valida็ใo de Idade"
		lRet := .F.
	EndIf
Else
	If M->GA7_IDAMIN > 0 .And. M->GA7_IDAMAX == 0
		HS_MsgInf(STR0039, STR0012, STR0040) //"A idade mแxima deve ser maior que a idade mํnima."###"Aten็ใo"###"Valida็ใo de Idade"
		lRet := .F.
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A28Pct บAutor  ณDaniel Peixoto      บ Data ณ  17/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta as Regras relacionadas a cada pacote(Procedimento)    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A28Pct(cAlias, nReg, nOpc)

Local aAreaOld   := GetArea()
Local nOpcA      := 0, nGDOpc := IIF(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local bFS_FacExc	:= {||FS_FacExc(aRotina[nOpc, 4])} // Facilitador para copia dos diferenciados de um plano para outro
Local oDlg
Local aButtons   := {}, bKeyf4
Local aSize      := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local cOrd       := 0
Local cPesq      := Space(100)
Local cFolder    := ""

Private cGP0CodPro  := ""
Private nCont       := 0
Private cCodPro     := "", cCodCon := ""
Private cGa7TipPro  := "9"
Private nGP0_CODCON := 0, nGP0_STAREG := 0
Private nGP1_SEQPRO := 0, nGP1_PROSEC := 0, nGP1_QTDPRO := 0
Private nGP2_SEQGPP := 0, nGP2_CODGPP := 0
Private nGP3_SEQTXD := 0, nGP3_CODTXD := 0, nGP3_QTDTXD := 0
Private nGP4_SEQCTD := 0, nGP4_CODCTD := 0
Private nGP5_SEQMED := 0, nGP5_CODMED := 0, nGP5_QTDMED := 0
Private nGP6_SEQGRP := 0, nGP6_CODGRP := 0
Private nGP7_SEQMAT := 0, nGP7_CODMAT := 0, nGP7_QTDMAT := 0
Private nGP8_SEQGRP := 0, nGP8_CODGRP := 0

Private oGP0, oGP1, oGP2, oGP3, oGP5, oGP6, oGP7, oGP8, oFolder, oCBx, oBigGet
Private aCGP0	:= {}, aHGP0 := {}, nUGP0 := 0, nLGP0 := 0
Private aCGP1	:= {}, aHGP1 := {}, nUGP1 := 0, nLGP1 := 0, aIGP1 := {}
Private aCGP2	:= {}, aHGP2 := {}, nUGP2 := 0, nLGP2 := 0, aIGP2 := {}
Private aCGP3	:= {}, aHGP3 := {}, nUGP3 := 0, nLGP3 := 0, aIGP3 := {}
Private aCGP4	:= {}, aHGP4 := {}, nUGP4 := 0, nLGP4 := 0, aIGP4 := {}
Private aCGP5	:= {}, aHGP5 := {}, nUGP5 := 0, nLGP5 := 0, aIGP5 := {}
Private aCGP6	:= {}, aHGP6 := {}, nUGP6 := 0, nLGP6 := 0, aIGP6 := {}
Private aCGP7	:= {}, aHGP7 := {}, nUGP7 := 0, nLGP7 := 0, aIGP7 := {}
Private aCGP8	:= {}, aHGP8 := {}, nUGP8 := 0, nLGP8 := 0, aIGP8 := {}
Private aTela := {}, aGets := {}

If GA7->GA7_TIPPRO # "9"
	HS_MsgInf(STR0018, STR0012, STR0021) //"Procedimento nใo ้ do tipo 'Pacote'."###"Aten็ใo"###"Pacote"
	Return(Nil)
EndIf

oGP1:= ""
oGP2:= ""
oGP3:= ""
oGP4:= ""
oGP5:= ""
oGP6:= ""
oGP7:= ""
oGP8:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inclusao dos botoes dos facilitadores ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aButtons	, {'PARAMETROS',{||Eval(bFS_FacExc)}, STR0019, STR0020})  //"Gerar exce็๕es de um conv๊nio para outro."###"Gerar"
bKeyf4 :=	SetKey( VK_F4, { || Eval(bFS_FacExc)})

cCodPro := GA7->GA7_CODPRO

HS_BDados("GP0", @aHGP0, @aCGP0, @nUGP0, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP0->GP0_CODPRO", Nil), .T.,,,,, "BR_CINZA")
nGP0_CODCON := aScan(aHGP0, {| aVet | aVet[2] == "GP0_CODCON"})
nGP0_STAREG := aScan(aHGP0, {| aVet | aVet[2] == "HSP_STAREG"})

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 030, .T., .T. } )
AAdd( aObjects, { 100, 055, .T., .T. } )
AAdd( aObjects, { 100, 015, .T., .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

nOpcA := 0

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0021 + ": " + cCodPro) From 00, 0 To 38, 110 Of oMainWnd  //"Pacote"

oGP0 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc, "HS_A28LOK(0)",,,,,,,,, oDlg, aHGP0, aCGP0)
oGP0:oBrowse:Align := CONTROL_ALIGN_TOP
oGP0:bChange := {|| FS_StaReg(oGP0, nGP0_STAREG), HS_GERACOLS(nOpc)}
oGP0:oBrowse:bGotFocus := {|| FS_StaReg(oGP0, nGP0_STAREG)}

HS_GERACOLS(nOpc)

@ 150, 000 FOLDER oFolder SIZE 435, 160 Of oDlg PROMPTS STR0022, STR0023, STR0024, STR0025, STR0026, STR0027, STR0028, STR0029 PIXEL  //"Procedimento"###"Grupo Procedimento"###"Taxas"###"Grupos Taxas"###"Medicamento"###"Grupo Medicamento"###"Materiais"###"Grupo Materiais"
oFolder:Align  := CONTROL_ALIGN_ALLCLIENT
oFolder:bChange:= {|| HS_GDPesqu( , , &("oGP" + Str(oFolder:nOption, 1)), oPPesq, 002)}

oGP1 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(1)",, "+GP1_SEQPRO",,, 99999,,,, oFolder:aDialogs[1], aHGP1, aCGP1)
oGP1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP2 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(2)",, "+GP2_SEQGPP",,, 99999,,,, oFolder:aDialogs[2], aHGP2, aCGP2)
oGP2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP3 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(3)",, "+GP3_SEQTXD",,, 99999,,,, oFolder:aDialogs[3], aHGP3, aCGP3)
oGP3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP4 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(4)",, "+GP4_SEQCTD",,, 99999,,,, oFolder:aDialogs[4], aHGP4, aCGP4)
oGP4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP5 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(5)",, "+GP5_SEQMED",,, 99999,,,, oFolder:aDialogs[5], aHGP5, aCGP5)
oGP5:oBrowse:bGotFocus := {|| cG1RTipo := "1"}
oGP5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP6 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(6)",, "+GP6_SEQGRP",,, 99999,,,, oFolder:aDialogs[6], aHGP6, aCGP6)
oGP6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP7 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(7)",, "+GP7_SEQMAT",,, 99999,,,, oFolder:aDialogs[7], aHGP7, aCGP7)
oGP7:oBrowse:bGotFocus := {|| cG1RTipo := "0"}
oGP7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGP8 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_A28LOK(8)",, "+GP8_SEQGRP",,, 99999,,,, oFolder:aDialogs[8], aHGP8, aCGP8)
oGP8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oPPesq	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4])
oPPesq:Align := CONTROL_ALIGN_BOTTOM

HS_GDPesqu( , , &("oGP"+Str(oFolder:nOption, 1)), oPPesq, 002)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. ;
																																																																			FS_TudoOK("GP1", oGP1, nGP1_PROSEC) .And. ;
																																																																			FS_TudoOK("GP2", oGP2, nGP2_CODGPP) .And. ;
																																																																			FS_TudoOK("GP3", oGP3, nGP3_CODTXD) .And. ;
																																																																			FS_TudoOK("GP5", oGP5, nGP5_CODMED) .And. ;
																																																																			FS_TudoOK("GP6", oGP6, nGP6_CODGRP) .And. ;
																																																																			FS_TudoOK("GP7", oGP7, nGP7_CODMAT) .And. ;
																																																																			FS_TudoOK("GP8", oGP8, nGP8_CODGRP), 	oDlg:End(), nOpcA == 0)}, ;
																																																		{|| nOpcA := 0, oDlg:End()},, aButtons)

SetKey(VK_F4, bKeyF4)
If nOpcA == 1
	FS_GrvPct(nOpc)
EndIf

RestArea(aAreaOld)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GerACols  บ Autor ณ Daniel Peixoto  บ Data ณ  17/01/06   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera AHEADER E Acols das Tabelas GP1-GP2-GP3-GP4-GP5-GP6   บฑฑ
ฑฑบ          ณ                                  GP7-GP8                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function HS_GerACols(nOpc)

Local nX         := 0
Local nPos       := 0
Local lExclui    := .F.
Local nCt        := 0
Private cG1RTipo := ""

If ValType(oGP1) == "O"
	nCont++
	If nCont > 1
		//Verifica se foi marcada para exclusao alguma linha do aCols.

		For nCt:= 1  To Len(oGP1:aCols)
			If oGP1:aCols[nCt, Len(oGP1:aHeader) + 1]
				lExclui := .T.
				Exit
			EndIf
		Next

		If !lExclui
			For nCt := 1 To Len(oGP2:aCols)
				If oGP2:aCols[nCt, Len(oGP2:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(oGP3:aCols)
				If oGP3:aCols[nCt, Len(oGP3:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(oGP4:aCols)
				If oGP4:aCols[nCt, Len(oGP4:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(oGP5:aCols)
				If oGP5:aCols[nCt, Len(oGP5:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(oGP6:aCols)
				If oGP6:aCols[nCt, Len(oGP6:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(oGP7:aCols)
				If oGP7:aCols[nCt, Len(oGP7:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(oGP8:aCols)
				If oGP8:aCols[nCt, Len(oGP8:aHeader) + 1]
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If oGP0:lChgField .Or. oGP1:lChgField .Or. oGP2:lChgField .Or. oGP3:lChgField .Or. oGP4:lChgField .Or. oGP5:lChgField .Or. oGP6:lChgField .Or. oGP7:lChgField .Or. oGP8:lChgField .Or. lExclui //Verifica se houve modificacao em uma das linhas dos acols.
			If MsgYesNo(STR0030) //"Deseja gravar registro(s)? "
				FS_GrvPct(nOpc)
  		oGP0:lChgField := .F.   //Retorna o status de nao modificado para as linhas dos acols.
				oGP1:lChgField := .F.
				oGP2:lChgField := .F.
				oGP3:lChgField := .F.
				oGP4:lChgField := .F.
				oGP5:lChgField := .F.
				oGP6:lChgField := .F.
				oGP7:lChgField := .F.
				oGP8:lChgField := .F.
			EndIf
		EndIf
	EndIf

EndIf

aCGP1	:= {}
aHGP1 := {}
nUGP1 := 0
nLGP1 := 0

aCGP2	:= {}
aHGP2 := {}
nUGP2 := 0
nLGP2 := 0

aCGP3	:= {}
aHGP3 := {}
nUGP3 := 0
nLGP3 := 0

aCGP4	:= {}
aHGP4 := {}
nUGP4 := 0
nLGP4 := 0

aCGP5	:= {}
aHGP5 := {}
nUGP5 := 0
nLGP5 := 0

aCGP6	:= {}
aHGP6 := {}
nUGP6 := 0
nLGP6 := 0

aCGP7	:= {}
aHGP7 := {}
nUGP7 := 0
nLGP7 := 0

aCGP8	:= {}
aHGP8 := {}
nUGP8 := 0
nLGP8 := 0

HS_BDados("GP1", @aHGP1, @aCGP1, @nUGP1, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP1->GP1_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP1->GP1_CODCON", Nil))
nGP1_SEQPRO := aScan(aHGP1, {| aVet | aVet[2] == "GP1_SEQPRO"})
nGP1_PROSEC := aScan(aHGP1, {| aVet | aVet[2] == "GP1_PROSEC"})
nGP1_QTDPRO := aScan(aHGP1, {| aVet | aVet[2] == "GP1_QTDPRO"})

If Empty(aCGP1[1, nGP1_PROSEC])
	aCGP1[1, nGP1_SEQPRO] := StrZero(1, Len(GP1->GP1_SEQPRO))
EndIf

HS_BDados("GP2", @aHGP2, @aCGP2, @nUGP2, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP2->GP2_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP2->GP2_CODCON", Nil))
nGP2_SEQGPP := aScan(aHGP2, {| aVet | aVet[2] == "GP2_SEQGPP"})
nGP2_CODGPP := aScan(aHGP2, {| aVet | aVet[2] == "GP2_CODGPP"})

If Empty(aCGP2[1, nGP2_CODGPP])
	aCGP2[1, nGP2_SEQGPP] := StrZero(1, Len(GP2->GP2_SEQGPP))
EndIf

HS_BDados("GP3", @aHGP3, @aCGP3, @nUGP3, 1, , IIf(nOpc # 3, "'" + cCodPro + "' == GP3->GP3_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP3->GP3_CODCON", Nil))
nGP3_SEQTXD := aScan(aHGP3, {| aVet | aVet[2] == "GP3_SEQTXD"})
nGP3_CODTXD := aScan(aHGP3, {| aVet | aVet[2] == "GP3_CODTXD"})
nGP3_QTDTXD := aScan(aHGP3, {| aVet | aVet[2] == "GP3_QTDTXD"})

If Empty(aCGP3[1, nGP3_CODTXD])
	aCGP3[1, nGP3_SEQTXD] := StrZero(1, Len(GP3->GP3_SEQTXD))
EndIf

HS_BDados("GP4", @aHGP4, @aCGP4, @nUGP4, 1, , IIf(nOpc # 3, "'" + cCodPro + "' == GP4->GP4_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP4->GP4_CODCON", Nil))
nGP4_SEQCTD := aScan(aHGP4, {| aVet | aVet[2] == "GP4_SEQCTD"})
nGP4_CODCTD := aScan(aHGP4, {| aVet | aVet[2] == "GP4_CODCTD"})

If Empty(aCGP4[1, nGP4_CODCTD])
	aCGP4[1, nGP4_SEQCTD] := StrZero(1, Len(GP4->GP4_SEQCTD))
EndIf

HS_BDados("GP5", @aHGP5, @aCGP5, @nUGP5, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP5->GP5_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP5->GP5_CODCON", Nil))
nGP5_SEQMED := aScan(aHGP5, {| aVet | aVet[2] == "GP5_SEQMED"})
nGP5_CODMED := aScan(aHGP5, {| aVet | aVet[2] == "GP5_CODMED"})
nGP5_QTDMED := aScan(aHGP5, {| aVet | aVet[2] == "GP5_QTDMED"})

If Empty(aCGP5[1, nGP5_CODMED])
	aCGP5[1, nGP5_SEQMED] := StrZero(1, Len(GP5->GP5_SEQMED))
EndIf

HS_BDados("GP6", @aHGP6, @aCGP6, @nUGP6, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP6->GP6_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP6->GP6_CODCON", Nil))
nGP6_SEQGRP := aScan(aHGP6, {| aVet | aVet[2] == "GP6_SEQGRP"})
nGP6_CODGRP := aScan(aHGP6, {| aVet | aVet[2] == "GP6_CODGRP"})

If Empty(aCGP6[1, nGP6_CODGRP])
	aCGP6[1, nGP6_SEQGRP] := StrZero(1, Len(GP6->GP6_SEQGRP))
EndIf

HS_BDados("GP7", @aHGP7, @aCGP7, @nUGP7, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP7->GP7_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP7->GP7_CODCON", Nil))
nGP7_SEQMAT := aScan(aHGP7, {| aVet | aVet[2] == "GP7_SEQMAT"})
nGP7_CODMAT := aScan(aHGP7, {| aVet | aVet[2] == "GP7_CODMAT"})
nGP7_QTDMAT := aScan(aHGP7, {| aVet | aVet[2] == "GP7_QTDMAT"})

If Empty(aCGP7[1, nGP7_CODMAT])
	aCGP7[1, nGP7_SEQMAT] := StrZero(1, Len(GP7->GP7_SEQMAT))
EndIf

HS_BDados("GP8", @aHGP8, @aCGP8, @nUGP8, 1, , IIF(nOpc # 3, "'" + cCodPro + "' == GP8->GP8_CODPRO .AND. '" + oGP0:aCols[oGP0:nAt, nGP0_CODCON] + "' == GP8->GP8_CODCON", Nil))
nGP8_SEQGRP := aScan(aHGP8, {| aVet | aVet[2] == "GP8_SEQGRP"})
nGP8_CODGRP := aScan(aHGP8, {| aVet | aVet[2] == "GP8_CODGRP"})

If Empty(aCGP8[1, nGP8_CODGRP])
	aCGP8[1, nGP8_SEQGRP] := StrZero(1, Len(GP8->GP8_SEQGRP))
EndIf

If ValType(oGP1) == "O"
	oGP1:Acols := aClone(ACGP1)
	oGP2:Acols := aClone(ACGP2)
	oGP3:Acols := aClone(ACGP3)
	oGP4:Acols := aClone(ACGP4)
	oGP5:Acols := aClone(ACGP5)
	oGP6:Acols := aClone(ACGP6)
	oGP7:Acols := aClone(ACGP7)
	oGP8:Acols := aClone(ACGP8)

	oGP1:oBrowse:Refresh()
	oGP2:oBrowse:Refresh()
	oGP3:oBrowse:Refresh()
	oGP4:oBrowse:Refresh()
	oGP5:oBrowse:Refresh()
	oGP6:oBrowse:Refresh()
	oGP7:oBrowse:Refresh()
	oGP8:oBrowse:Refresh()
EndIf

cCodCon := oGP0:aCols[oGP0:nAt, nGP0_CODCON]

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TudoOK บ Autor ณ Daniel Peixoto     บ Data ณ  17/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verificacao de validade da confirmacao de atualizacao      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_TudoOK(cAlias, oOK, nPos)

Local lRet 			:= .T.
Local lCond   := .F.

If ValType(oOK:aCols[1, nPos]) == "C"
	lCond := !Empty(oOK:aCols[1, nPos])
ElseIf ValType(oOK:aCols[1, nPos]) == "N"
	lCond := !oOK:aCols[1, nPos] == 0
ElseIf ValType(oOK:aCols[1, nPos]) == "D"
	lCond := !oOK:aCols[1, nPos] == CTOD("  /  /  ")
EndIf

If Len(oOk:aCols) == 1 .And. lCond
	lRet := oOk:TudoOK()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvPct บ Autor ณ Daniel Peixoto     บ Data ณ  17/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Atualizacao das tabelas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvPct(nOpc)

Local lAchou  := .F., lExcConv := .F.
Local lRet    := .T.
Local nCt     := 0
Local lExclui := .F.

aCGP0 := aClone(oGP0:aCols)
aCGP1 := aClone(oGP1:aCols)
aCGP2 := aClone(oGP2:aCols)
aCGP3 := aClone(oGP3:aCols)
aCGP4 := aClone(oGP4:aCols)
aCGP5 := aClone(oGP5:aCols)
aCGP6 := aClone(oGP6:aCols)
aCGP7 := aClone(oGP7:aCols)
aCGP8 := aClone(oGP8:aCols)

If nOpc # 2 // nao for consulta

	If Inclui .Or. Altera

		//Pacote x Convenio
		For nCt := 1 To Len(aCGP0)
			If !Empty(aCGP0[nCt, nGP0_CODCON])
				DbselectArea("GP0")
				DbsetOrder(1) // GP0_FILIAL + GP0_CODPRO + GP0_CODCON
				lAchou := DbSeek(xFilial("GP0") + cCodPro + aCGP0[nCt, nGP0_CODCON])
				If aCGP0[nCt, Len(aHGP0) + 1] .And. lAchou//exclusao
					RecLock("GP0", .F., .T.)
					DbDelete()
					MsUnlock()
					WriteSx2("GP0")
					//Exclui todos os relacionamentos do pacote x convenio
					FS_Deleta("GP1", 1, "cCodPro + cCodCon + aCGP1[pForACols, nGP1_SEQPRO]", aCGP1, nGP1_PROSEC)  // Excluir relacionamento GP1
					FS_Deleta("GP2", 1, "cCodPro + cCodCon + aCGP2[pForACols, nGP2_SEQGPP]", aCGP2, nGP2_CODGPP)  // Excluir relacionamento GP2
					FS_Deleta("GP3", 1, "cCodPro + cCodCon + aCGP3[pForACols, nGP3_SEQTXD]", aCGP3, nGP3_CODTXD)  // Excluir relacionamento GP3
					FS_Deleta("GP4", 1, "cCodPro + cCodCon + aCGP4[pForACols, nGP4_SEQCTD]", aCGP4, nGP4_CODCTD)  // Excluir relacionamento GP4
					FS_Deleta("GP5", 1, "cCodPro + cCodCon + aCGP5[pForACols, nGP5_SEQMED]", aCGP5, nGP5_CODMED)  // Excluir relacionamento GP5
					FS_Deleta("GP6", 1, "cCodPro + cCodCon + aCGP6[pForACols, nGP6_SEQGRP]", aCGP6, nGP6_CODGRP)  // Excluir relacionamento GP6
					FS_Deleta("GP7", 1, "cCodPro + cCodCon + aCGP7[pForACols, nGP7_SEQMAT]", aCGP7, nGP7_CODMAT)  // Excluir relacionamento GP7
					FS_Deleta("GP8", 1, "cCodPro + cCodCon + aCGP8[pForACols, nGP8_SEQGRP]", aCGP8, nGP8_CODGRP)  // Excluir relacionamento GP8
					lExcConv := .T.
					Exit
				Else //inclusao ou alteracao
					If !Empty(aCGP0[nCt, nGP0_CODCON])
						RecLock("GP0", !lAchou)
 						HS_GRVCPO("GP0", aCGP0, aHGP0, nCt)
						 GP0->GP0_FILIAL := xFilial("GP0")
	 					GP0->GP0_CODPRO := cCodPro
						MsUnlock()
						If !lAchou //inclusao
							FS_Grava("GP1", 1, "cCodPro + cCodCon + aCGP1[pForACols, nGP1_SEQPRO]", aHGP1, aCGP1, nUGP1, nGP1_PROSEC)
							FS_Grava("GP2", 1, "cCodPro + cCodCon + aCGP2[pForACols, nGP2_SEQGPP]", aHGP2, aCGP2, nUGP2, nGP2_CODGPP)
							FS_Grava("GP3", 1, "cCodPro + cCodCon + aCGP3[pForACols, nGP3_SEQTXD]", aHGP3, aCGP3, nUGP3, nGP3_CODTXD)
							FS_Grava("GP4", 1, "cCodPro + cCodCon + aCGP4[pForACols, nGP4_SEQCTD]", aHGP4, aCGP4, nUGP4, nGP4_CODCTD)
							FS_Grava("GP5", 1, "cCodPro + cCodCon + aCGP5[pForACols, nGP5_SEQMED]", aHGP5, aCGP5, nUGP5, nGP5_CODMED)
							FS_Grava("GP6", 1, "cCodPro + cCodCon + aCGP6[pForACols, nGP6_SEQGRP]", aHGP6, aCGP6, nUGP6, nGP6_CODGRP)
							FS_Grava("GP7", 1, "cCodPro + cCodCon + aCGP7[pForACols, nGP7_SEQMAT]", aHGP7, aCGP7, nUGP7, nGP7_CODMAT)
							FS_Grava("GP8", 1, "cCodPro + cCodCon + aCGP8[pForACols, nGP8_SEQGRP]", aHGP8, aCGP8, nUGP8, nGP8_CODGRP)
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		//Relacionamentos
		If !lExclui
			For nCt := 1 To Len(aCGP1)
				If aCGP1[nCt, Len(aHGP1) + 1]
					FS_Deleta("GP1", 1, "cCodPro + cCodCon + aCGP1[pForACols, nGP1_SEQPRO]", aCGP1, nGP1_PROSEC)  // Excluir relacionamento GP1
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP2)
				If aCGP2[nCt, Len(aHGP2) + 1]
					FS_Deleta("GP2", 1, "cCodPro + cCodCon + aCGP2[pForACols, nGP2_SEQGPP]", aCGP2, nGP2_CODGPP)  // Excluir relacionamento GP2
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP3)
				If aCGP3[nCt, Len(aHGP3) + 1]
					FS_Deleta("GP3", 1, "cCodPro + cCodCon + aCGP3[pForACols, nGP3_SEQTXD]", aCGP3, nGP3_CODTXD)  // Excluir relacionamento GP3
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP4)
				If aCGP4[nCt, Len(aHGP4) + 1]
					FS_Deleta("GP4", 1, "cCodPro + cCodCon + aCGP4[pForACols, nGP4_SEQCTD]", aCGP4, nGP4_CODCTD)  // Excluir relacionamento GP4
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP5)
				If aCGP5[nCt, Len(aHGP5) + 1]
					FS_Deleta("GP5", 1, "cCodPro + cCodCon + aCGP5[pForACols, nGP5_SEQMED]", aCGP5, nGP5_CODMED)  // Excluir relacionamento GP5
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP6)
				If aCGP6[nCt, Len(aHGP6) + 1]
					FS_Deleta("GP6", 1, "cCodPro + cCodCon + aCGP6[pForACols, nGP6_SEQGRP]", aCGP6, nGP6_CODGRP)  // Excluir relacionamento GP6
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP7)
				If aCGP7[nCt, Len(aHGP7) + 1]
					FS_Deleta("GP7", 1, "cCodPro + cCodCon + aCGP7[pForACols, nGP7_SEQMAT]", aCGP7, nGP7_CODMAT)  // Excluir relacionamento GP7
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExclui
			For nCt := 1 To Len(aCGP8)
				If aCGP8[nCt, Len(aHGP8) + 1]
					FS_Deleta("GP8", 1, "cCodPro + cCodCon + aCGP8[pForACols, nGP8_SEQGRP]", aCGP8, nGP8_CODGRP)  // Excluir relacionamento GP8
					lExclui := .T.
					Exit
				EndIf
			Next
		EndIf

		If !lExcConv
			FS_Grava("GP1", 1, "cCodPro + cCodCon + aCGP1[pForACols, nGP1_SEQPRO]", aHGP1, aCGP1, nUGP1, nGP1_PROSEC)
			FS_Grava("GP2", 1, "cCodPro + cCodCon + aCGP2[pForACols, nGP2_SEQGPP]", aHGP2, aCGP2, nUGP2, nGP2_CODGPP)
			FS_Grava("GP3", 1, "cCodPro + cCodCon + aCGP3[pForACols, nGP3_SEQTXD]", aHGP3, aCGP3, nUGP3, nGP3_CODTXD)
			FS_Grava("GP4", 1, "cCodPro + cCodCon + aCGP4[pForACols, nGP4_SEQCTD]", aHGP4, aCGP4, nUGP4, nGP4_CODCTD)
			FS_Grava("GP5", 1, "cCodPro + cCodCon + aCGP5[pForACols, nGP5_SEQMED]", aHGP5, aCGP5, nUGP5, nGP5_CODMED)
			FS_Grava("GP6", 1, "cCodPro + cCodCon + aCGP6[pForACols, nGP6_SEQGRP]", aHGP6, aCGP6, nUGP6, nGP6_CODGRP)
			FS_Grava("GP7", 1, "cCodPro + cCodCon + aCGP7[pForACols, nGP7_SEQMAT]", aHGP7, aCGP7, nUGP7, nGP7_CODMAT)
			FS_Grava("GP8", 1, "cCodPro + cCodCon + aCGP8[pForACols, nGP8_SEQGRP]", aHGP8, aCGP8, nUGP8, nGP8_CODGRP)
		EndIf

	Else  // exclusao
		FS_Deleta("GP1", 1, "cCodPro + cCodCon + aCGP1[pForACols, nGP1_SEQPRO]", aCGP1, nGP1_PROSEC)  // Excluir relacionamento GP1
		FS_Deleta("GP2", 1, "cCodPro + cCodCon + aCGP2[pForACols, nGP2_SEQGPP]", aCGP2, nGP2_CODGPP)  // Excluir relacionamento GP2
		FS_Deleta("GP3", 1, "cCodPro + cCodCon + aCGP3[pForACols, nGP3_SEQTXD]", aCGP3, nGP3_CODTXD)  // Excluir relacionamento GP3
		FS_Deleta("GP4", 1, "cCodPro + cCodCon + aCGP4[pForACols, nGP4_SEQCTD]", aCGP4, nGP4_CODCTD)  // Excluir relacionamento GP4
		FS_Deleta("GP5", 1, "cCodPro + cCodCon + aCGP5[pForACols, nGP5_SEQMED]", aCGP5, nGP5_CODMED)  // Excluir relacionamento GP5
		FS_Deleta("GP6", 1, "cCodPro + cCodCon + aCGP6[pForACols, nGP6_SEQGRP]", aCGP6, nGP6_CODGRP)  // Excluir relacionamento GP6
		FS_Deleta("GP7", 1, "cCodPro + cCodCon + aCGP7[pForACols, nGP7_SEQMAT]", aCGP7, nGP7_CODMAT)  // Excluir relacionamento GP7
		FS_Deleta("GP8", 1, "cCodPro + cCodCon + aCGP8[pForACols, nGP8_SEQGRP]", aCGP8, nGP8_CODGRP)  // Excluir relacionamento GP8
	EndIf

EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Grava  บ Autor ณ Daniel Peixoto     บ Data ณ  17/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento - GP1, G  , G  , G  , G   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Grava(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv, nPos)

Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
Local cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local lCond   := .F.

If ValType(aCGrv[1, nPos]) == "C"
	lCond := !Empty(aCGrv[1, nPos])
ElseIf ValType(aCGrv[1, nPos]) == "N"
	lCond := !aCGrv[1, nPos] == 0
ElseIf ValType(aCGrv[1, nPos]) == "D"
	lCond := !aCGrv[1, nPos] == CTOD("  /  /  ")
EndIf

If Len(aCGrv) > 1 .Or. lCond
	For nForACols := 1 To Len(aCGrv)
		pForACols := nForACols

		DbSelectArea(cAlias)
		DbSetOrder(nOrd)
		lAchou := DbSeek(xFilial(cAlias) + &(cChave))
		If aCGrv[nForACols, Len(aHGrv) + 1] .And. lAchou // exclusao
			RecLock(cAlias, .F.)
			DbDelete()
			MsUnlock()
		Else //inclui ou altera
			If !aCGrv[nForACols, nUGrv + 1]
				RecLock(cAlias, !lAchou)
				HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
				&(cPref + "_FILIAL") := xFilial(cAlias)
				&(cPref + "_CODPRO") := cCodPro
				&(cPref + "_CODCON") := cCodCon
				&(cPref + "_LOGARQ") := HS_LogArq()
				MsUnlock()
			EndIf
		EndIf
	Next
EndIf
DbSelectArea(cAliasOld)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Deleta บ Autor ณ Daniel Peixoto     บ Data ณ  17/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de DELETE dos relacionamentos dos Pacotes           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Deleta(cAlias, nOrd, cChave, aCGrv, nPos)

Local nForDel := 0, cAliasOld := Alias()
Local lCond   := .F.

If Len(aCGrv) <= 0
	Return(Nil)
EndIf

If ValType(aCGrv[1, nPos]) == "C"
	lCond := !Empty(aCGrv[1, nPos])
ElseIf ValType(aCGrv[1, nPos]) == "N"
	lCond := !aCGrv[1,nPos]==0
ElseIf ValType(aCGrv[1, nPos]) == "D"
	lCond := !aCGrv[1, nPos] == CTOD("  /  /  ")
EndIf

If Len(aCGrv) > 1 .Or. lCond
	For nForDel := 1 To Len(aCGrv)
		pForACols := nForDel

		DbSelectArea(cAlias)
		DbSetOrder(nOrd)
		If DbSeek(xFilial(cAlias) + &(cChave))
			RecLock(cAlias, .F.)
			DbDelete()
			MsUnlock()
		EndIf
	Next
EndIf

DbSelectArea(cAliasOld)
Return(Nil)


Function HS_A28LOK(nFolder)

Local lRet := .T.

If nFolder == 0
	lRet := HS_DuplAC(oGP0:oBrowse:nAt, oGP0:aCols, {nGP0_CODCON})
ElseIf nFolder == 1
	lRet := HS_DuplAC(oGP1:oBrowse:nAt, oGP1:aCols, {nGP1_PROSEC})
ElseIf nFolder == 2
	lRet := HS_DuplAC(oGP2:oBrowse:nAt, oGP2:aCols, {nGP2_CODGPP})
ElseIf nFolder == 3
	lRet := HS_DuplAC(oGP3:oBrowse:nAt, oGP3:aCols, {nGP3_CODTXD})
ElseIf nFolder == 4
	lRet := HS_DuplAC(oGP4:oBrowse:nAt, oGP4:aCols, {nGP4_CODCTD})
ElseIf nFolder == 5
	lRet := HS_DuplAC(oGP5:oBrowse:nAt, oGP5:aCols, {nGP5_CODMED})
ElseIf nFolder == 6
	lRet := HS_DuplAC(oGP6:oBrowse:nAt, oGP6:aCols, {nGP6_CODGRP})
ElseIf nFolder == 7
	lRet := HS_DuplAC(oGP7:oBrowse:nAt, oGP7:aCols, {nGP7_CODMAT})
ElseIf nFolder == 8
	lRet := HS_DuplAC(oGP8:oBrowse:nAt, oGP8:aCols, {nGP8_CODGRP})
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FacExc บ Autor ณ Daniel Peixoto     บ Data ณ  09/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Facilitador: copia as excecoes   de um convenio ja cadast. บฑฑ
ฑฑบ          ณ para o convenio posicionado                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FacExc(nOpc)

Local aAlias       := {"GP1","GP2","GP3","GP4","GP5","GP6","GP7","GP8"}
Local aParm        := {}
Local nNum         := 0
Local lSai         := .F.
Local lCancel      := .F.
Local lPgHSPA28    := .F.

Private cCodCon_Pa := HS_IniPadR("GP0", 1, cCodPro + oGP0:aCols[oGP0:nAt, nGP0_CODCON], "GP0_CODCON",, .F.)
Private cCodCon_De := ""
Private cGP0CodPro := cCodPro

If Empty(cCodCon_Pa)
	HS_MsgInf(STR0031, STR0012, STR0021)  //"Nenhum conv๊nio foi cadastrado. Verifique!"###"Aten็ใo"###"Pacote"
	Return()
EndIf

If !MsgYesNo(OEmToAnsi(STR0032 + cCodCon_Pa + "?")) //"Tem certeza que deseja copiar as exce็๕es para o conv๊nio?"
	Return()
EndIf
lPgHSPA28 := Pergunte("HSPA28", .T.) 
While !lSai

	If !lPgHSPA28
		lCancel := .T.
		lSai    := .T.
	Else
		If MV_PAR02 == 2 .And. MV_PAR03 == 2 .And. MV_PAR04 == 2 .And. MV_PAR05 == 2 .And. ;
			MV_PAR06 == 2 .And. MV_PAR07 == 2 .And. MV_PAR08 == 2 .And. MV_PAR09 == 2
			HS_MsgInf(STR0033	, STR0012, STR0038)  //"Selecione pelo menos um dos itens de exce็๕es"###"Aten็ใo"###"Botใo 'Facilitador'"
		Else
			lSai := .T.
		EndIf
	EndIf

EndDo

If lCancel
	Return()
EndIf

aParm := {MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Copia os diferenciados do plano De para o plano selecionado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nNum := 1 To Len(aAlias)

	If aParm[nNum] == 1   //1=Sim   2=Nao
		FS_ACopiar(aAlias[nNum])
	EndIf

Next nNum

DbSelectArea("GCM")
DbSetOrder(1) // GCM_FILIAL + GCM_CODCON + GCM_CODPLA

HS_GERACOLS(nOpc)

DbSelectArea("GCM")

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_FILA28 บ Autor ณ Daniel Peixoto     บ Data ณ  09/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao das perguntas.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_FilA28()

Local cAliasOld := Alias(), lRet := .T.

cCodCon_De := HS_IniPadR("GP0", 1, cCodPro + MV_PAR01, "GP0_CODCON",, .F.)

If Empty(cCodCon_De)
	HS_MsgInf(STR0035, STR0021, STR0012) //"Conv๊nio invแlido"###"Pacote"###"Aten็ใo"
	lRet := .F.

ElseIf cCodCon_De == cCodCon_Pa
	HS_MsgInf(STR0036, STR0034, STR0012)  //"Conv๊nios informados iguais. Verifique!"###"Conv๊nios"###"Aten็ใo"
	lRet := .F.

ElseIf Empty(HS_IniPadR("GA9", 1, cCodCon_De, "GA9_CODCON",, .F.))
	HS_MsgInf(STR0037, STR0021, STR0012)  //"Conv๊nio nใo cadastrado."###"Pacote"###"Aten็ใo"
	lRet := .F.
EndIf

DbSelectArea(cAliasOld)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ACopiarบ Autor ณ Daniel Peixoto     บ Data ณ  09/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Copia as ocorrencias de diferenciado do plano de para o    บฑฑ
ฑฑบ          ณ plano selecionado                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ACopiar(cAlias)

Local nLCop  := 0
Local aCCop  := {}
Local aHCop  := {}
Local nUCop  := 0
Local cPref  := cAlias + "->" + PrefixoCpo(cAlias)
Local nForL  := 0
Local nForC  := 0
Local cChave := ""
Local cItem  := ""
Local nItem  := 0
Local cCond  := cPref + "_CODPRO = '" + cCodPro + "' AND " + cPref + "_CODCON == '" + cCodCon_De + "'"

nLCop := HS_BDados(cAlias, @aHCop, @aCCop, @nUCop, 1, , cCond,,,,,, .F.)

If cAlias == "GP1"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP1_PROSEC] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP1_PROSEC]
		EndIf
	Next nForL

ElseIf cAlias == "GP2"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP2_CODGPP] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP2_CODGPP]
		EndIf
	Next nForL

ElseIf cAlias == "GP3"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP3_CODTXD] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP3_CODTXD]
		EndIf
	Next nForL

ElseIf cAlias == "GP4"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP4_CODCTD] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP4_CODCTD]
		EndIf
	Next nForL

ElseIf cAlias == "GP5"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP5_CODMED] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP5_CODMED]
		EndIf
	Next nForL

ElseIf cAlias == "GP6"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP6_CODGRP] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP6_CODGRP]
		EndIf
	Next nForL

ElseIf cAlias == "GP7"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP7_CODMAT] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP7_CODMAT]
		EndIf
	Next nForL

ElseIf cAlias == "GP8"
	For nForL := 1 To nLCop
		If aCCop[nForL, nGP8_CODGRP] == cChave
			aCCop[nForL, nUCop + 1] := .T.
		Else
			cChave := aCCop[nForL, nGP8_CODGRP]
		EndIf
	Next nForL

EndIf

If &("nL" + cAlias) == 0 .And. nLCop > 0
	&("o" + cAlias + ":aCols") := {}
EndIf

For nForL := 1 To nLCop

	If !aCCop[nForL, nUCop + 1]
		&("o" + cAlias + ":AddLine(.F., .F.)")
		&("o" + cAlias + ":lNewLine") := .F.

		&("nL"+cAlias) += 1

		For nForC := 1 To len(aCCop[nForL])
			If !Empty(cItem) .And. nForC == nItem //Se for o item ou a prioridade... soma 1
				cItem := STRZERO(Val(cItem) + 1, Len(cItem))
				&("o" + cAlias + ":aCols")[&("nL" +cAlias), nForC] := cItem
			Else
				&("o" + cAlias + ":aCols")[&("nL" + cAlias), nForC] := aCCop[nForL, nForC]
			EndIf
		Next nForC

	EndIf

Next nForL

&("o" + cAlias):lChgField := .T.

If nLCop > 0
	&("o" + cAlias):oBrowse:Refresh()
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VA28SUSบAutor  ณLuiz Pereira S. Jr. บ Data ณ  18/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo dos campos referentes ao SUS                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Admistracao Hospitalar                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VA28SUS()

 Local lRet:= .T.

 If ReadVar() == "M->GHH_CODCID"
  If !(lRet := HS_SeekRet("GAS", "M->GHH_CODCID", 1, .F., "GHH_DESCID","GAS_PATOLO"))
	 	HS_MsgInf(STR0041, STR0012, STR0013) //"Patologia nใo cadastrada."###"Aten็ใo"###"Valida็ใo de campos"
	 EndIf
	ElseIf ReadVar() == "M->GHG_CDTATE"
	 If !(lRet := HS_SeekRet("GH4","M->GHG_CDTATE", 1, .F., "GHG_DSTATE", "GH4_DSTATE"))
 	 HS_MsgInf(STR0042, STR0012, STR0013) // "Tipo de Atendimento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos"
	 EndIf
	ElseIf ReadVar() == "M->GHF_CDGATE"
	 If !(lRet := HS_SeekRet("GH3", "M->GHF_CDGATE", 1, .F., "GHF_DSGATE", "GH3_DSGATE"))
	  HS_MsgInf(STR0043, STR0012, STR0013)  // "Grupo de Atendimento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos"
	 EndIf
	ElseIf ReadVar() == "M->GHD_CODCBO"
	 If !(lRet := HS_SeekRet("GN1", "M->GHD_CODCBO", 1, .F., "GHD_DESCBO", "GN1_DESCBO") )
 	 HS_MsgInf(STR0044, STR0012, STR0013)  //"Ocupa็ใo nใo cadastrada."###"Aten็ใo"###"Valida็ใo de campos"
	 EndIf
ElseIf ReadVar() == "M->GTL_CODCRI"
	If !(lRet := HS_SeekRet("GTK", "M->GTL_CODCRI", 1, .F., "GTL_DESCRI", "GTK_DESCR") )
		HS_MsgInf(STR0074, STR0012, STR0013)  //"Critica Nใo Cadastrada" ###"Aten็ใo"###"Valida็ใo de campos"
	EndIf

EndIf


Return(lRet)


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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"  	, 0, 1, 0, nil} ,; 	//"Pesquisar"
					 {OemToAnsi(STR0003), 'HS_A28'   	, 0, 2, 0, nil} ,; 	//"Visualizar"
					 {OemToAnsi(STR0004), 'HS_A28'   	, 0, 3, 0, nil} ,; 	//"Incluir"
					 {OemToAnsi(STR0005), 'HS_A28'   	, 0, 4, 0, nil} ,; 	//"Alterar"
					 {OemToAnsi(STR0006), 'HS_A28'   	, 0, 5, 0, nil} ,; 	//"Excluir"
					 {OemToAnsi(STR0021), 'HS_A28Pct'	, 0, 4, 0, nil},;	//"Pacote"
					 {OemToAnsi(STR0066), 'HS_A28SB1'	, 0, 4, 0, nil},;	//"Cad. Produto"
		    		 {OemToAnsi(STR0067), 'HS_A28'  	, 0, 4, 0, nil}}	//"Copiar"}

Aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GA7',GA7->GA7_CODPRO, 1)})", 0 , K_Visualizar})
Aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GA7',GA7->GA7_CODPRO, 0)})", 0 , K_Visualizar})

Return(aRotina)

Static Function FS_StaReg(oObj, nPosCol)
Local nCont := 0
Local nPos  := 0

 oObj:aCols[oObj:nAt, nPosCol] := "BR_VERDE"

 While (nPos := aScan(oObj:aCols, {|x| x[nPosCol] == "BR_VERDE"}, nPos + 1)) > 0
  If nPos <> oObj:nAt
   oObj:aCols[nPos, nPosCol] := "BR_CINZA"
  EndIf
 End

 oObj:Refresh()

Return()
Function HS_RDesc28(nCpo)
Local cDesc  := ""

 If !Inclui

  If nCpo == 1

   cDesc := HS_IniPadr("GJS", 1, SubStr(GA7->GA7_CODSUS, 1, 2), "GJS_DSGSUS")

  ElseIf nCpo == 2

   cDesc := HS_IniPadr("GJC", 1, SubStr(GA7->GA7_CODSUS, 1, 4), "GJC_DSGSUS")

  ElseIf nCpo == 3

   cDesc := HS_IniPadr("GJD", 1, SubStr(GA7->GA7_CODSUS , 1, 6), "GJD_DESCRI")

  EndIf
 EndIf

Return(cDesc)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ AjustaSX1ณ Autor ณ MICROSIGA             ณ Data ณ 25/11/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Verifica as perguntas incluindo-as caso nao existam        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Uso Generico.                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AjustaSX1()
Local aArea		:= GetArea()
Local aRegs		:= {}
Local i			:= 0
Local j			:= 0
Local lInclui	:= .F.
Local aHelpPor	:= {}
Local cPerg:= PADR("HSPA28",6)


aRegs	:= {}

AADD(aRegs,{cPerg,"01","Do Convenio ?                 ","ฟDe Convenio ?                ","From healthcare ?             ","MV_CH0","C",03,00,00,"G","HS_FilA28()                                                 ","MV_PAR01       ","               ","               ","               ","001                                                         ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","GA9   ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"02","Procedimentos ?               ","ฟProcedimientos ?             ","Procedures ?                  ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR02       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"03","Grupo Proced. ?               ","ฟGrupo Proced. ?              ","Proc. Group ?                 ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR03       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"04","Taxas ?                       ","ฟTasas ?                      ","Rates ?                       ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR04       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"05","Grupo Taxas ?                 ","ฟGrupo Tasas ?                ","Rates Group ?                 ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR05       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"06","Medicamentos ?                ","ฟMedicamentos ?               ","Medicines ?                   ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR06       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"07","Grupo Medicam. ?              ","ฟGrupo Medicam. ?             ","Medicines Group ?             ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR07       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"08","Materiais ?                   ","ฟMateriales ?                 ","Material ?                    ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR08       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})
AADD(aRegs,{cPerg,"09","Grupo Materiais ?             ","ฟGrupo Materiales ?           ","Material Group ?              ","MV_CH0","N",01,00,01,"C","                                                            ","MV_PAR09       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","N","   ","          ","                                        ","      "})

dbSelectArea("SX1")
dbSetOrder(1)
For i := 1 To Len(aRegs)
	lInclui := !dbSeek(cPerg + "    " + aRegs[i,2])
	RecLock("SX1", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Endif
	Next
	MsUnlock()

	aHelpPor := {}

	IF i == 1
		AADD(aHelpPor,"Informe o Codigo do Convenio  ")
		AADD(aHelpPor,"Cujo as Exce็oes serใo  copiadas ")
		AADD(aHelpPor,"para o Convenio posicionado  ")
		AADD(aHelpPor,"na tela de pacote. ")
		AADD(aHelpPor,"O convenio  Selecionado  ")
		AADD(aHelpPor,"deverแ ser diferente ")
		AADD(aHelpPor,"do Convenio  posicionado")
		AADD(aHelpPor,"na tela de pacote .")

	ELSEIF i==2
		AADD(aHelpPor,"Informe se serใo copiadas as    ")
		AADD(aHelpPor,"informa็๕es referente aos ")
		AADD(aHelpPor,"Procedimentos do Convenio Selecionado   ")


	ELSEIF i==3
		AADD(aHelpPor," Informe se serใo copiadas as   ")
		AADD(aHelpPor," informa็๕es referente ao       ")
		AADD(aHelpPor," Grupo Proced do Convenio Selecionado ")


	ELSEIF i==4
		AADD(aHelpPor," Informe se serใo copiadas as   ")
		AADD(aHelpPor," informa็๕es referente a Taxas  ")
		AADD(aHelpPor," do Convenio Selecionado.       ")

	ELSEIF i==5
		AADD(aHelpPor," Informe se serใo copiadas as   ")
		AADD(aHelpPor," informa็๕es referente ao  ")
		AADD(aHelpPor," Grupo de Taxas do Convenio Selecionado. ")



	ELSEIF i==6
		AADD(aHelpPor,"Informe se serใo copiadas as   ")
		AADD(aHelpPor,"informa็๕es referente a Medicamentos ")
		AADD(aHelpPor,"do Convenio Selecionado. ")

	ELSEIF i==7
		AADD(aHelpPor,"Informe se serใo copiadas as   ")
		AADD(aHelpPor,"informa็๕es referente ao ")
		AADD(aHelpPor,"Grupo Medicamento Convenio Selecionado  ")



	ELSEIF i==8
		AADD(aHelpPor,"Informe se serใo copiadas as   ")
		AADD(aHelpPor,"informa็๕es referente a Materiais")
		AADD(aHelpPor,"do Convenio Selecionado. ")

	ELSEIF i==9
		AADD(aHelpPor,"Informe se serใo copiadas as   ")
		AADD(aHelpPor,"informa็๕es referente ao ")
		AADD(aHelpPor,"Grupo Materiais do Convenio Selecionado ")


	ENDIF
    PutSX1Help("P."+cPerg+strzero(i,2)+".",aHelpPor)
Next

RestArea(aArea)
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSXB บAutor  ณMicrosiga           บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada, para realizar a criacao da consulta padrao   บฑฑ
ฑฑบ          ณGMV Procedimentos SUS.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSXB()
Local aArea			:= GetArea()
Local i      		:= 0
Local j      		:= 0
Local aRegs  		:= {}
Local lInclui		:= .F.

aRegs  := {}
AADD(aRegs,{"GMV   ","1","01","DB","Procedimento SUS    "	,"Procedimento SUS "	,"Procedimento SUS       "	,"GMV                                                                                                                                                                                                                                                       "	,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","2","01","01","Codigo SUS             ","Cod SUS             "	,"Cod SUS             "		,"                                                                                                                                                                                                                                                "				,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","2","02","02","Descricao           "	,"Descricao           "	,"Descricao           "		,"                                                                                                                                                                                                                                                "				,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","4","01","01","Codigo SUS             ","Cod SUS             "	,"Cod SUS             "		,"GMV_CODPRO                                                                                                                                                                                                                                                "	,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","4","01","02","Descricao           "	,"Descricao           "	,"Descricao           "		,"GMV_DESCRI                                                                                                                                                                                                                                                "	,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","4","02","01","Codigo SUS             ","Cod SUS             "	,"Cod SUS             "		,"GMV_CODPRO                                                                                                                                                                                                                                                "	,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","4","02","02","Descricao           "	,"Descricao           "	,"Descricao           "		,"GMV_DESCRI                                                                                                                                                                                                                                                "	,"                                                                                                                                                                                                                                                          "})
AADD(aRegs,{"GMV   ","5","01","  ","                    "	,"                    "	,"                    "		,"GMV->GMV_CODPRO                                                                                                                                                                                                                                           "	,"                                                                                                                                                                                                                                                          "})

dbSelectArea("SXB")
dbSetOrder(1)

For i := 1 To Len(aRegs)

	dbSetOrder(1)
	lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4])

	RecLock("SXB", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			If allTrim(Field(j)) == "X2_ARQUIVO"
				aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
			EndIf
			If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
				Loop
			Else
				FieldPut(j,aRegs[i,j])
			EndIf
		Endif
	Next
	MsUnlock()
Next i

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A28SB1 บAutor  ณRogerio Tabosa      บ Data ณ  15/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCaso o produto possua vinculo com aSB1(cadastro de produtos)บฑฑ
ฑฑ           ณabre janela para altera็ใo								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A28SB1()
Local aArea		:= GetArea()
Local cCodSb1 	:= PADR(GA7->GA7_CODPRO, TAMSX3("B1_COD")[1])
Local aCpos		:= {"B1_COD", "B1_DESC" , "B1_TIPO","B1_UM","B1_LOCPAD"}

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1") + cCodSb1)
	AxAltera("SB1", SB1->(Recno()),4,,aCpos)
Else
	HS_MSGINF(STR0068,STR0012, STR0013) //"Procedimento nใo possui vinculo com o cadastro de produto!"
EndIf

RestArea(aArea)
Return()

Static Function FS_RETPRC(cCodPro)
Local aArea		:= GetArea()
Local aRVldVig := {{0, "GA8_VLRPRO"}}
Local nPreco	:= 0

HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_CODPRO = '" + cCodPro + "'", "GA8_DATVIG", @aRVldVig, dDataBase)
nPreco := aRVldVig[1,1]
RestArea(aArea)

Return(nPreco)

/*
###################################################################################
###################################################################################
### Programa  # fs_vldGTL     ### Autor #  Saude       ### Data #   24/05/2012  ###
###################################################################################
### Descricao # Valida os dados inseridos na aba "criticas" para dente/face     ###
###################################################################################
### Parametro #                                                                 ###
###################################################################################
### Retorno   #                                                                 ###
###           # lRet    : Informa se o registro pode ser alterado/incluido      ###
###################################################################################
### Uso       # GH                                                              ###
###################################################################################
*/
static function fs_vldGTL()
local lCriDeReFa := SuperGetMV("MV_CRITDRF", NIL, .F.) .And. SuperGetMV("MV_CRITCLI", NIL, .F.)
local lRet     := .T.
local nI       := 0
local cCodDen := ""
local cCodFac := ""
local cCodCri := ""

if lCriDeReFa
	for nI := 1 to len(oGTL:aCols)
		cCodDen := oGTL:aCols[nI, nGTLCODDEN]
		cCodFac := oGTL:aCols[nI, nGTLCODFAC]
		cCodCri := oGTL:aCols[nI, nGTLCODIGO]
		if !empty(cCodDen) .and. empty(cCodFac)
			HS_MsgInf("Informe o campo " + alltrim(Posicione("SX3", 2, "GTL_CODFAC" ,"X3_TITULO")) + ;
			" para a crํtica (" + alltrim(Posicione("SX3", 2, "GTL_CODCRI" ,"X3_TITULO")) + ") " +;
			cCodCri + " - " + alltrim(Posicione("GTK", 1, xFilial("GTK") + cCodCri ,"GTK_DESCR"))  + ;
			" e para o Dente/Regiใo (" + alltrim(Posicione("SX3", 2, "GTL_CODDEN" ,"X3_TITULO")) + ") " + ;
			cCodDen + " - " + alltrim(Posicione("B04", 1, xFilial("B04") + cCodDen ,"B04_DESCRI")) + ;
			" na pasta Crํticas", STR0012, STR0013) // ### "Aten็ใo" ### "Valida็ใo de campos"
			lRet := .F.
		elseif empty(cCodDen) .and. !empty(cCodFac)
			HS_MsgInf("Informe o campo " + alltrim(Posicione("SX3", 2, "GTL_CODDEN" ,"X3_TITULO")) + ;
			" para a crํtica (" + alltrim(Posicione("SX3", 2, "GTL_CODCRI" ,"X3_TITULO")) + ") " +;
			cCodCri + " - " + alltrim(Posicione("GTK", 1, xFilial("GTK") + cCodCri ,"GTK_DESCR"))  + ;
			" e para a face (" + alltrim(Posicione("SX3", 2, "GTL_CODFAC" ,"X3_TITULO")) + ") " + ;
			cCodFac + " - " + alltrim(Posicione("B09", 1, xFilial("B09") + cCodFac ,"B09_FACDES")) + ;
			" na pasta Crํticas", STR0012, STR0013) // ### "Aten็ใo" ### "Valida็ใo de campos"
			lRet := .F.
		endif

	next nI
endif

return lRet
