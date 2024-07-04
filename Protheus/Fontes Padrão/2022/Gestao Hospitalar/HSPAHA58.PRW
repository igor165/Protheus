#INCLUDE "HSPAHA58.ch"
#include "protheus.CH"
#include "dbtree.ch"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA58  บ Autor ณ Manoel             บ Data ณ  12/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE PACIENTES                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHA58()
Local cAtuClie := GetNewPar("MV_ATUCLIE","S")

If !(cAtuClie $ "S/N")
	Hs_MsgInf(STR0053,STR0009,STR0054)//"Valor incorreto para param๊tro MV_ATUCLIE"###"Aten็ใo"###"Valida็ใo Param๊tro Atualiza Cliente(MV_ATUCLIE)"
	Return(nil)
EndIf

Private aRotina := {	{OemtoAnsi(STR0002), "axPesqui"		, 0, 1}, ; //"Pesquisar"
						{OemtoAnsi(STR0003), "HS_A58"		, 0, 2}, ; //"Visualizar"
						{OemtoAnsi(STR0004), "HS_A58"		, 0, 3}, ; //"Incluir"
						{OemtoAnsi(STR0005), "HS_A58"		, 0, 4}, ; //"Alterar"
						{OemtoAnsi(STR0006), "HS_A58"		, 0, 5}, ; //"Excluir"
						{OemtoAnsi(STR0020), "HS_ETQPACI()"	, 0, 3}, ; //"Etiqueta"
						{OemtoAnsi(STR0014), "HS_A58EXT"	, 0, 2}, ; //"Extrato"
						{OemtoAnsi(STR0031), "HS_PESQGD4"	, 0, 1} }  //"Carterinha"

mBrowse(06, 01, 22, 75, "GBH")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_A58   บ Autor ณ Cibele Peria       บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das Funcoes                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A58(cAlias,nReg,nOpc)
Local nOpcA := 0, nGDOpc := IIf(aRotina[nOpc, 4] == 2 .Or. aRotina[nOpc, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE), oDlgA58
Local oFolder, nRecnoGd4, lAchouGd4:= .F., oEnchoice
Local aButtons	:= 	{{"MAQFOTO", {|| HS_CapFoto(xFilial("GBH") + M->GBH_CODPAC, oEnchoice, "M->GBH_BITMAP")}, OemToAnsi( STR0042 ), OemToAnsi(STR0043)}} //"Obtem Foto <F4>..."###"Foto"
Local bKeyf4 :=	SetKey(VK_F4, {|| HS_CapFoto(xFilial("GBH") + M->GBH_CODPAC, oEnchoice, "M->GBH_BITMAP")})
Local cCpoNao := "", aCpoMark := {}, aMarDef := {}
Local lAteSus := IF(AllTrim(GetNewPar("MV_ATESUS","N"))=="S",.T.,.F.)
local lGfdResFin := HS_ExisDic({{"C", "GFD_RESFIN"}}, .F.)
Local lEspelhar := GetNewPar("MV_INTBTGB",.F.) // Parametro Integracao das Tabelas de vidas PLS X GH

Private aTela := {}, aGets := {}
Private aCGD4 := {}, aHGD4 := {}, nUGD4 := 0, nLGD4 := 0
Private aHGF1 := {}, aCGF1 := {}, nUGF1 := 0, nLGF1 := 0, oGF1
Private aHGFD := {}, aCGFD := {}, nUGFD := 0, nLGFD := 0, oGFD
Private oGD4, nGD4_IDDOAC := 0, nGD4_CODPLA := 0, nGD4_MATRIC := 0, nGD4_DTVALI := 0, nGD4_IDEATI := 0
Private aItensMar := {}
Private lEdtCodLoc := INCLUI .and. (FunName() == "HSPAHA58") //Campo lEdtCodLoc usado no dicionario (X3_WHEN) do campo GBH_CODLOC

Private cGBH_CEP 				:= ""
Private cGBH_END 				:= ""
Private cGBH_NUM 				:= ""
Private cGBH_MUN 				:= ""
Private cGBH_EST 				:= ""
Private cGBH_TEL 				:= ""
Private cGBH_BAIRRO  := ""
Private cGBH_COMPLE 	:= ""
Private cGBH_TIPLOG		:= ""
Private cGFVPlano    := ""
Private lGravaCli	:= .T.
Private cCliente	:= ""
Private cLojCli		:= ""
Private lExDicPacSUS := HS_ExisDic({{"C", "GBH_PACSUS"}}, .F.)

Private cAtuClie := GetNewPar("MV_ATUCLIE","S")//GetMV("MV_ATUCLIE",,"S")

Private aCGTN := {}, aHGTN := {}, nUGTN := 0, nLGTN := 0, nGTLCODIGO:=0
Private lExbCrit	:= SuperGetMV("MV_CRITCLI", NIL, .F.) //Verifica se Exibe o Folder Para Cadastro de Critica


 If !(cAtuClie $ "S/N")
  Hs_MsgInf(STR0053,STR0009,STR0054)//"Valor incorreto para param๊tro MV_ATUCLIE"###"Aten็ใo"###"Valida็ใo Param๊tro Atualiza Cliente(MV_ATUCLIE)"
  Return(nil)
 EndIf

	RegToMemory("GBH",(aRotina[nOpc, 4] == 3)) // Gera variavies de memoria para o GBH

	If Type("cAgdNomPac") <> "U" .And. (aRotina[nOpc, 4] == 3 .Or. FunName() == "HSPAHM39")
	 M->GBH_NOME := cAgdNomPac
	EndIf

	If Type("cAgdTelPac") <> "U" .And. (aRotina[nOpc, 4] == 3 .Or. FunName() == "HSPAHM39")
  M->GBH_TEL := cAgdTelPac
 EndIf

 If Type("cOrcSexo") <> "U" .And. (aRotina[nOpc, 4] == 3 .Or. FunName() $ "HSPM24AA/HSPM24AI")
 	M->GBH_SEXO := cOrcSexo
 EndIf

 If Type("cOrcDtNasc") <> "U" .And. (aRotina[nOpc, 4] == 3 .Or. FunName() $ "HSPM24AA/HSPM24AI")
  M->GBH_DTNASC := cOrcDtNasc
  M->GBH_IDADE  := HS_A58AGE()
 EndIf

  aMarDef  := {"IIf(GD4->GD4_IDPADR =='1','LBTIK','LBNO')","IIf(GD4->GD4_IDDOAC =='1','LBTIK','LBNO')"}
  aCpomark := {"GD4_IDPADR", "GD4_IDDOAC"}
  cCpoNao  := "GD4_IDPADR/GD4_IDDOAC"


 nLGD4 := HS_BDados("GD4", @aHGD4, @aCGD4, @nUGD4, 1, M->GBH_CODPAC, IIf(aRotina[nOpc, 4] # 3, "'" + M->GBH_CODPAC + "' == GD4->GD4_REGGER", Nil), , , , , cCpoNao, ,aCpoMark, aMarDef)
 nGD4_CODPLA := aScan(aHGD4, {| aVet | aVet[2] == "GD4_CODPLA"})
 nGD4_DESPLA := aScan(aHGD4, {| aVet | aVet[2] == "GD4_DESPLA"})
 nGD4_MATRIC := aScan(aHGD4, {| aVet | aVet[2] == "GD4_MATRIC"})
 nGD4_IDPADR := aScan(aHGD4, {| aVet | aVet[2] == "GD4_IDPADR"})
 nGD4_IDEATI := aScan(aHGD4, {| aVet | aVet[2] == "GD4_IDEATI"})
 nGD4_IDDOAC := aScan(aHGD4, {| aVet | aVet[2] == "GD4_IDDOAC"})
 nGD4_DTVALI := aScan(aHGD4, {| aVet | aVet[2] == "GD4_DTVALI"})
 nGD4_NOMTIT := aScan(aHGD4, {| aVet | aVet[2] == "GD4_NOMTIT"})
 nGD4_SQCATP := aScan(aHGD4, {| aVet | aVet[2] == "GD4_SQCATP"})
 nGD4_NMCATP := aScan(aHGD4, {| aVet | aVet[2] == "GD4_NMCATP"})




 If Type("cOrcCodPla") <> "U" .And. (aRotina[nOpc, 4] == 3 .Or. FunName() $ "HSPM24AA/HSPM24AI")
  aCGD4[1,  nGD4_CODPLA] := cOrcCodPla
  aCGD4[1,  nGD4_DESPLA] := HS_IniPadR("GCM", 2, cOrcCodPla, "GCM_DESPLA",, .F.)
 EndIf

 HS_BDados("GF1", @aHGF1, @aCGF1, @nUGF1, 1, M->GBH_CODPAC, "'" + M->GBH_CODPAC + "' == GF1->GF1_REGGER" )
 nGF1_SeqFon := aScan(aHGF1, {| aVet | aVet[2] == "GF1_SEQFON"})
 nOpcA   := 0

 HS_BDados("GFD", @aHGFD, @aCGFD, @nUGFD, 1, M->GBH_CODPAC, IIf(aRotina[nOpc, 4] # 3, "'" + M->GBH_CODPAC + "' == GFD->GFD_REGGER", Nil), , , , , "GFD_IDPADR", ,"GFD_IDPADR", "IIf(GFD->GFD_IDPADR =='1','LBTIK','LBNO')")
 nGFD_SeqRes := aScan(aHGFD, {| aVet | aVet[2] == "GFD_SEQRES"})
 nGFD_Nome   := aScan(aHGFD, {| aVet | aVet[2] == "GFD_NOME  "})
 nGFD_IDPadr := aScan(aHGFD, {| aVet | aVet[2] == "GFD_IDPADR"})
 nGFD_Idade  := aScan(aHGFD, {| aVet | aVet[2] == "GFD_IDADE "})
 nGFD_Cep    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_CEP   "})
 nGFD_Mun    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_MUN   "})
 nGFD_Est    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_EST   "})
 nGFD_Num    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_NUM   "})
 nGFD_Bairro := aScan(aHGFD, {| aVet | aVet[2] == "GFD_BAIRRO"})
 nGFD_End    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_END   "})
 nGFD_Tel    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_TEL   "})
 nGFD_Com    := aScan(aHGFD, {| aVet | aVet[2] == "GFD_COMPLE"})
 nGFD_CodNac := aScan(aHGFD, {| aVet | aVet[2] == "GFD_CODNAC"})
if lGfdResFin
	nGFD_ResFin := aScan(aHGFD, {| aVet | aVet[2] == "GFD_RESFIN"})
endif


If lExbCrit
	//nLGTN := HS_BDados("GTN", @aHGTN, @aCGTN, @nUGTN, 1,M->GBH_CODPAC ,IIF(aRotina[nOpc, 4] # 3,"GTN->GTN_CODPAC == '" + M->GBH_CODPAC + "'", Nil))
	//nGTNCODIGO := aScan(aHGTN, {| aVet | aVet[2] == "GTN_CODCRI"})

	nLGTN := HS_BDados("GTN", @aHGTN, @aCGTN, @nUGTN, 1, M->GBH_CODPAC, IIf(aRotina[nOpc, 4] # 3, "'" + M->GBH_CODPAC + "' == GTN->GTN_CODPAC", Nil), , , , , , ,,)
	//nGFD_SeqRes := aScan(aHGFD, {| aVet | aVet[2] == "GFD_SEQRES"})
	nGTNCODIGO := aScan(aHGTN, {| aVet | aVet[2] == "GTN_CODCRI"})
Endif

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 070, .T., .T. } )
 AAdd( aObjects, { 100, 030, .T., .T.,.T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlgA58 TITLE OemToAnsi(STR0001) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd//"Cadastro de Paciente"

  oEnchoice:=MsMGet():New("GBH", nReg, nOpc,,,,, aPObjs[1],,,,,,oDlgA58)
  oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

  /* Preenche as variaveis utilizadas na funcao FS_EndGFD com o valor do campo antes de ser alterado, ou seja, assim que ele recebe o focus */
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_CEP" 				$ aVet})]:BGOTFOCUS := {||	cGBH_CEP 					:= M->GBH_CEP,;
																																																																																																			cGBH_END 					:= M->GBH_END,;
																																																																																																			cGBH_MUN 					:= M->GBH_MUN,;
																																																																																																			cGBH_EST 					:= M->GBH_EST,;
																																																																																																			cGBH_BAIRRO 		:= M->GBH_BAIRRO}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_END" 				$ aVet})]:BGOTFOCUS := {|| cGBH_END 					:= M->GBH_END}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_NUM" 				$ aVet})]:BGOTFOCUS := {|| cGBH_NUM 					:= M->GBH_NUM}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_EST" 				$ aVet})]:BGOTFOCUS := {|| cGBH_EST 					:= M->GBH_EST}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_MUN" 				$ aVet})]:BGOTFOCUS := {|| cGBH_MUN 					:= M->GBH_MUN}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_TEL" 				$ aVet})]:BGOTFOCUS := {|| cGBH_TEL 					:= M->GBH_TEL}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_BAIRRO" 	$ aVet})]:BGOTFOCUS := {|| cGBH_BAIRRO 		:= M->GBH_BAIRRO}
		oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_COMPLE" 	$ aVet})]:BGOTFOCUS := {|| cGBH_COMPLE 		:= M->GBH_COMPLE}

    If lExbCrit
	    @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlgA58 Prompts STR0021, STR0022, STR0023, "Crํticas" //"Planos"###"Telefones"###"Responsแvel"
    Else
	    @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlgA58 Prompts STR0021, STR0022, STR0023 //"Planos"###"Telefones"###"Responsแvel"
    EndIf

  oFolder:Align := CONTROL_ALIGN_BOTTOM

  oGD4 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[1], aHGD4, aCGD4)
  oGD4:oBrowse:align:= CONTROL_ALIGN_ALLCLIENT

  oGF1 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[2], aHGF1, aCGF1)
  oGF1:oBrowse:align:=CONTROL_ALIGN_ALLCLIENT

  oGFD := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,,,,,,,, oFolder:aDialogs[3], aHGFD, aCGFD)
  oGFD:oBrowse:align:=CONTROL_ALIGN_ALLCLIENT
  oGFD:oBrowse:BlDblClick := {|| FS_ResDbC(oGFD:oBrowse:nAt)}
  oGFD:oBrowse:BADD       := {|| FS_NovLinR()}
  oGFD:oBrowse:bDelete    := {|| IIf(FS_VldDel("GFD"), oGFD:DELLINE(), .F.)}

  oGD4:oBrowse:BlDblClick := {|| FS_DblClk(oGD4:oBrowse:nAt)}
  If lExDicPacSUS .And. lAteSus
	  oGD4:oBrowse:bGotFocus  := {|| FS_PRESUS()}
	  oGD4:oBrowse:bLostFocus := {|| FS_REPDSUS()}
  EndIf
  oGD4:cFieldOk           := "HS_DuplA58()"
  If lExDicPacSUS
  	oGD4:bLinhaOK           := {|| FS_PlanoOK() ,FS_REPDSUS() }
  Else
    oGD4:bLinhaOK           := {|| FS_PlanoOK() }
  EndIf
  oGD4:oBrowse:BADD       := {|| FS_NovLin()}
  oGD4:oBrowse:bDelete    := {|| IIf(FS_VldDel("GD4"), oGD4:DELLINE(), .F.)}
  oGD4:bChange            := {|| FS_SetaPla() }

If lExbCrit
	/* Critica */
	oGTN := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGTN:oBrowse:nAt, oGTN:aCols, {nGTNCODIGO})",,,,,,,,, oFolder:aDialogs[4], aHGTN, aCGTN)
	oGTN:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif

  if (FunName() # "HSPAHA58").And.(aRotina[nOpc, 4] == 4)
   oEnchoice:AENTRYCTRLS[aScan(oEnchoice:aGets, {| aVet | "GBH_NOME" 	$ aVet})]:SetFocus()
  endIf

 ACTIVATE MSDIALOG oDlgA58 ON INIT EnchoiceBar(oDlgA58, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. FS_VldOkCPF() .and. FS_TudoOK(oGD4, nGD4_CODPLA) .and. FS_TudoOK(oGFD, nGFD_Nome) .and. FS_ValId() .and. If (HS_ExisDic({{"C", "GBH_NUMCNS"}}, .F.), FS_PreCNS() .AND. FS_CNSDUP(), .T.), oDlgA58:End(), nOpcA := 0)}, ;
                                                        {|| nOpcA := 0, oDlgA58:End()},, aButtons)

 If (nOpcA == 1) .And. (aRotina[nOpc, 4] # 2)

  Begin Transaction
   If Type("cGbhRg") <> "U"
	   cGbhRg := M->GBH_RG
	  EndIf

   If Type("cGbhRgOrg") <> "U"
	   cGbhRgOrg := M->GBH_ORGEMI
	  EndIf

   If Type("cGbhUFEmis") <> "U"
	   cGbhUFEmis := M->GBH_UFEMIS
	  EndIf
   If Type("cAgdNomPac") <> "U" .And. (FunName() == "HSPAHM39")
	   cAgdNomPac := M->GBH_NOME
	  EndIf

	  If Type("cAgdTelPac") <> "U" .And. (FunName() == "HSPAHM39")
	   cAgdTelPac := M->GBH_TEL
	  EndIf

	  If Type("cAgdRegGer") <> "U" .And. (FunName() == "HSPAHM39")
	   cAgdRegGer := M->GBH_CODPAC
	  EndIf

	  If Inclui .And. FunName() == "HSPAHP12"
	  	Inclui := .F.
	  EndIf

   FS_GrvA58(aRotina[nOpc, 4])
   FS_GrvGF1()
   FS_GrvGFD()

   If lExbCrit
	FS_GrvGD("GTN", 1, oGTN:aCols, aHGTN, nUGTN, nGTNCODIGO, nGTNCODIGO, nOpc)
   Endif

   nRecnoGd4 := GD4->(Recno())
   DbSelectArea("GD4")
   DbSetOrder(2) //GD4_FILIAL+GD4_REGGER+GD4_IDPADR
   If DbSeek(xFilial("GD4")+ M->GBH_CODPAC + "1")
    lAchouGd4 :=.T.
   EndIf


	  If Type("cAgdCodPla") <> "U" .And. (FunName() == "HSPAHM39") .And. lAchouGd4
     cAgdCodPla := GD4->GD4_CODPLA
   EndIf

   If Type("cAgdMatric") <> "U" .And. (FunName() == "HSPAHM39") .And. lAchouGd4
     cAgdMatric := GD4->GD4_MATRIC
   EndIf

   DbGoto(nRecnoGd4)

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Ponto de entrada - HSA58OK ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If ExistBlock("HSA58OK")
    ExecBlock("HSA58OK", .F., .F., {cAlias, nReg, nOpc})
   EndIf
  End Transaction

  While __lSx8
   ConfirmSx8()
  EndDo
 Else
  While __lSx8
   RollBackSx8()
  EndDo
 EndIf

 SetKey(VK_F4, bKeyf4)
Return(nOpcA == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA58 บ Autor ณ Cibele Peria       บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de atualizacao                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvA58(nOpc)
Local lRet := .T., wProcura := .F., lAchou := .F., nForACols := 0
Local nForDel := 0
Local lGfdResFin := HS_ExisDic({{"C", "GFD_RESFIN"}}, .F.)
Local nI         := 0
local lEspelhar:=GetNewPar("MV_INTBTGB",.F.)
local LNovBTS:=.f.
Local cVlCod          := ""
Local cCodBTS         := ""
Local lMatvid:=HS_EXISDIC({{"C", "GBH_MATVID"}},.F.)

If nOpc # 2 // nao for consulta

	CursorWait()

	If Inclui
  		M->GBH_CODPAC := HS_VSxeNum("GBH", "M->GBH_CODPAC", 1)
	Endif
    If !Inclui // Para inclusใo nใo ้ necessแrio posicionar
	  	DbSelectArea("GBH")
	  	DBSetOrder(1)								// GBH_FILIAL + GBH_CODPAC
	  	wProcura := dbseek(xFilial("GBH") + M->GBH_CODPAC)
	EndIf
  	If Inclui .Or. Altera
   		If lRet := HS_IncSa1(nOpc)
    		RecLock("GBH", nOpc == 3)
    		If Altera
    			FS_AtuPac()
    		EndIf
     		HS_GRVCPO("GBH")
		    GBH->GBH_LOGARQ := HS_LogArq()
		    MsUnlock()

			If len(oGFD:aCols) >=1 .and. lGfdResFin
				For nI := 1 to len(oGFD:aCols)
					If oGFD:aCols[nI,1] =="LBTIK" .and. !oGFD:aCols[nI,len(oGFD:aHeader)+1] .and.  lGfdResFin .AND. !Empty(oGFD:aCols[nI,nGFD_ResFin])
						RecLock("GBH", .F.)
						GBH->GBH_CODCLI := oGFD:aCols[nI,nGFD_ResFin] //Codigo Cliente //
						MsUnlock()
					Endif
				Next nI
			Endif

    		If !( len(oGD4:aCols) == 1 .And. Empty(oGD4:aCols[1,nGD4_CODPLA]) )

  	 			For nForACols := 1 To Len(oGD4:aCols)
	    			DbSelectArea("GD4")
	      			DbSetOrder(1) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
			      	lAchou := DbSeek(xFilial("GD4") + GBH->GBH_CODPAC + oGD4:aCols[nForACols, nGD4_CODPLA] )
			      	If oGD4:aCols[nForACols, nUGD4+1] .And. lAchou        // exclusao
				 	    RecLock("GD4", .F., .T.)
				        DbDelete()
				       	MsUnlock()
      				Else
				       	If !oGD4:aCols[nForACols, nUGD4+1]
        					RecLock("GD4", !lAchou)
        					HS_GRVCPO("GD4", oGD4:aCols, oGD4:aHeader, nForACols)
					        GD4_FILIAL := xFilial("GD4")
					        GD4->GD4_IDPADR := IIf(oGD4:aCols[nForACols,nGD4_IDPADR] == "LBNO","0","1")
					        GD4->GD4_IDDOAC := IIf(oGD4:aCols[nForACols,nGD4_IDDOAC] == "LBNO","0","1")
					        GD4_REGGER := GBH->GBH_CODPAC
			      			GD4_CODCON := Posicione("GCM", 2, xFilial("GCM") + oGD4:aCols[nForACols, nGD4_CODPLA], "GCM_CODCON")
    					    GD4_LOGARQ := HS_LogArq()
        					MsUnlock()
       					Endif
		      		Endif
     			Next
				If lEspelhar  .and. lMatvid

		   //	Se tiver tiver integra็ใo do Pls vou atualizar a GD4 por aqui
					 HS_INCLGD4(GBH->GBH_CODPAC,GBH->GBH_MATVID)
			Endif
		 	Endif
   		EndIf

   		If nOpc == 4
    		dbSelectArea("GCY")
    		dbSetOrder(2) // GCY_FILIAL + GCY_REGGER
    		IF dbseek(xFilial("GBH") + M->GBH_CODPAC)
    			While !Eof() .And. GCY->GCY_FILIAL == xFilial("GCY") .And. GCY->GCY_REGGER == M->GBH_CODPAC
	      			RecLock("GCY", .F.)
	       			GCY->GCY_SEXO := GBH->GBH_SEXO
	      			MsUnlock()
	      			dbSkip()
     			Enddo
    		EndIf

		    dbSelectArea("GO0")
		    dbSetOrder(5) // GO0_FILIAL + GO0_REGGER
		    IF dbseek(xFilial("GBH") + M->GBH_CODPAC)
     			While !Eof() .And. GO0->GO0_FILIAL == xFilial("GO0") .And. GO0->GO0_REGGER == M->GBH_CODPAC
	      			RecLock("GO0", .F.)
	       			GO0->GO0_SEXO := GBH->GBH_SEXO
	      			MsUnlock()
      				dbSkip()
     			Enddo
    		EndIf
   		EndIf

		If Inclui
			If lEspelhar

				If  ! Empty(M->GBH_MATVID)
					DbSelectArea("BTS")
					BTS->(DbSetOrder(1))
					lNovBTS := (BTS->(MsSeek(xFilial("BTS")+M->GBH_MATVID)))
				Endif
			//Else
			//	lNovBTS := .T.


				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica se deve criar bts vida no plano de Saudeณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If  ! LNovBTS
					DbSelectArea("BBL")
					BBL->(DbSetOrder(2))
					If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHA58  "+"GBH"+"BTS"))
						BTS->(RecLock("BTS",(nOpc == 3)))
						cVlCod          := CriaVar("BTS_MATVID")
						cCodBTS         := If(!Empty(cVlCod),cVlCod,GetSX8Num("BTS","BTS_MATVID"))
						BTS->BTS_FILIAL := xFilial("BTS")
						BTS->BTS_MATVID := cCodBTS
						GBH->GBH_MATVID   := cCodBTS

						Do Case
							Case GBH->GBH_SEXO  == "0"
								BTS->BTS_SEXO:="1"
							Case GBH->GBH_SEXO == "1"
								BTS->BTS_SEXO:= "2"
						EndCase

						Do Case
							Case GBH->GBH_ESTCIV  == "0"
								BTS->BTS_ESTCIV:="C"
							Case GBH->GBH_ESTCIV == "1"
								BTS->BTS_ESTCIV:= "S"
							Case GBH->GBH_ESTCIV == "2"
								BTS->BTS_ESTCIV:= "D"
							Case GBH->GBH_ESTCIV == "3"
								BTS->BTS_ESTCIV:= "M"
							Case GBH->GBH_ESTCIV == "4"
								BTS->BTS_ESTCIV:= "V"

						EndCase

						//	BTS->BTS_MATVID := GETSX8NUM("BTS","BTS_MATVID")
						PlsSinc("HSPAHA58","GBH","BTS",.T.)
						BTS->(MsUnLock())
					Else
						If GetNewPar("MV_PLSMSGS","1") == "1"
							MsgAlert(OemtoAnsi("Arquivo de sincronismo entre BTS x GBH nao esta integro. Verifique!")) //
						Endif
					Endif

				Endif
			Endif
		Endif

		If Altera
			If lEspelhar .AND. lRet

				DbSelectArea("BBL")
				BBL->(DbSetOrder(2))

				DbSelectArea("BTS")
				BTS->(DbSetOrder(1))
				If BTS->(MsSeek(xFilial("BTS")+M->GBH_MATVID))
					If BBL->(MsSeek(xFilial("BBL")+"HSPAHA58  "+"GBH"+"BTS"))
						BTS->(RecLock("BTS",.F.))
						BTS->BTS_FILIAL := xFilial("BTS")

						Do Case
							Case M->GBH_SEXO  == "0" // CIRURGICA
								BTS->BTS_SEXO:="1"
							Case M->GBH_SEXO == "1"
								BTS->BTS_SEXO:= "2"
						EndCase

						Do Case
							Case M->GBH_ESTCIV  == "0" // CIRURGICA
								BTS->BTS_ESTCIV:="C"
							Case M->GBH_ESTCIV == "1"
								BTS->BTS_ESTCIV:= "S"
							Case M->GBH_ESTCIV == "2"
								BTS->BTS_ESTCIV:= "D"
							Case M->GBH_ESTCIV == "3"
								BTS->BTS_ESTCIV:= "M"
							Case M->GBH_ESTCIV == "4"
								BTS->BTS_ESTCIV:= "V"
						EndCase

						PlsSinc("HSPAHA58","GBH","BTS",.T.)
						BTS->(MsUnLock())
					Else
						If GetNewPar("MV_PLSMSGS","1") == "1"
							MsgAlert(OemtoAnsi("Arquivo de sincronismo entre BTS x GBH nao esta integro. Verifique!")) //
						Endif
					Endif
					DbSelectArea("BA1")
					BA1->(DbSetOrder(7))
					If BA1->(MsSeek(xFilial("BA1")+M->GBH_MATVID))
						If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHA58  "+"GBH"+"BA1"))
							RecLock("BA1", .F.)
							PlsSinc("HSPAHA58","GBH","BA1",.T.)
							MsUnlock()
						Else
							If GetNewPar("MV_PLSMSGS","1") == "1"
								MsgAlert(OemtoAnsi("Arquivo de sincronismo entre BTS x BA1 nao esta integro. Verifique!"))
							Endif
						Endif

					Endif

				Endif
			Endif
		Endif


  	Else  // exclusao
	   	If lRet := HS_IncSa1(nOpc)
	    	If wProcura
		     	If !( len(oGD4:aCols) == 1 .And. Empty(oGD4:aCols[1,nGD4_CODPLA]) )
			      	For nForDel := 1 To Len(oGD4:aCols)
				       	DbSelectArea("GD4")
				       	DbSetOrder(1)  // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
				       	If DbSeek(xFilial("GD4") + GBH->GBH_CODPAC + oGD4:aCols[nForDel,nGD4_CODPLA])
					        RecLock("GD4", .F., .T.)
					        DbDelete()
					        MsUnlock()
				       	Endif
			      	Next
		     	Endif
				If lEspelhar
					DbSelectarea ("GBH")
					GBH->(DbSetOrder(8))
					If GBH->(MsSeek(xFilial("GBH")+BTS->BTS_MATVID)) .and. HS_A58DOK(BTS->BTS_MATVID)
						DbSelectarea ("BBL")
						BBL->(DbSetOrder(2))
						If BBL->(MsSeek(xFilial("BBL")+"HSPAHA58  "+"GBH"+"BTS"))
							RecLock("GBH", .F.)
							DbDelete()
							MsUnlock()
						Else
							If GetNewPar("MV_PLSMSGS","1") == "1"
								MsgAlert(OemtoAnsi("Arquivo de sincronismo entre BTS x GBH nao esta integro. Verifique!"))
							Endif
						Endif

					Endif
				Endif

		     	DbSelectArea("GBH")
		     	RecLock("GBH", .F., .T.)
		     	DBDelete()
		     	MsUnlock()
	    	Endif
		Endif
 	Endif

  	CursorArrow()

EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA58 บ Autor ณ Cibele Peria       บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao dos edicao dos campos                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldA58()
Local lRet		:= .T.
Local aAreaOld	:= GetArea()
Local nCont		:= 0
Local cCampo	:= ReadVar()
Local lExistBA1:=.F.
Local lEspelhar := GetNewPar("MV_INTBTGB",.F.)

If cCampo == "M->GBH_CODLOC"
	DbSelectArea("GCS")
	DbSetOrder(1) // GCS_FILIAL + GCS_CODLOC
	If DbSeek(xFilial("GCS") + M->GBH_CODLOC)
		M->GBH_NOMLOC := GCS->GCS_NOMLOC //GDFieldPut("GBH_NOMLOC", GCS->GCS_NOMLOC)
	Else
		HS_MsgInf(STR0015, STR0008, STR0030) //"Setor invแlido"###"Verifique"###"Valida็ใo da digita็ใo"
	Endif
ElseIf cCampo == "M->GBH_DTNASC"
	If M->GBH_DTNASC > dDataBase
		HS_MsgInf(STR0028, STR0009, STR0030) //"Data de Nascimento posterior a data atual!"###"Aten็ใo"###"Valida็ใo da digita็ใo"
		lRet := .F.
	Else
		M->GBH_IDADE := HS_A58AGE()
	Endif

ElseIf cCampo == "M->GD4_CODPLA"
	DbSelectArea("GCM")
	DbSetOrder(2)		//GCM_FILIAL + GCM_CODPLA
	lRet := DbSeek(xFilial("GCM") + M->GD4_CODPLA)
	If lRet
		DbSelectArea("GA9")
		DbSetOrder(1) // GA9_FILIAL + GA9_CODCON
		If Dbseek(xFilial("GA9") + GCM->GCM_CODCON)
			If GA9->GA9_TIPCON == "1"
				oGD4:aCols[oGD4:oBrowse:nAT,nGD4_DTVALI]:= ctod(str(day(ddatabase) )+"/"+ str(month(ddatabase)) + "/" + (str(year(ddatabase)+100)))
			Else
				oGD4:aCols[oGD4:oBrowse:nAT,nGD4_DTVALI]:= CTOD("  /  /  ")
			Endif
		Endif
	Endif
	GDFieldPut("GD4_DESPLA", GCM->GCM_DESPLA)
	If !lRet
		HS_MsgInf(STR0007, STR0008, STR0030) //"Plano invแlido"###"Verifique"###"Valida็ใo da digita็ใo"
	Endif

ElseIf cCampo == "M->GD4_IDPADR"
	M->GD4_IDPADR := IIF(M->GD4_IDPADR == "LBTIK","LBTIK","LBNO")
ElseIf cCampo == "M->GFD_IDPADR"
	M->GFD_IDPADR := IIF(M->GFD_IDPADR == "LBTIK","LBTIK","LBNO")

ElseIf cCampo == "M->GFD_DTNASC" /* Data de nascimento do Responsavel */

	cIdade := HS_AGEGER(M->GFD_DTNASC)
	If !HS_VMAIOR(cIdade)
		HS_MsgInf(STR0033, STR0009, STR0030) //"O Responsแvel deve ser maior de idade."###"Aten็ใo"###"Valida็ใo da digita็ใo"
		lRet := .F.
	Else
		oGFD:aCols[oGFD:oBrowse:nAT,nGFD_IDADE] := cIdade
	EndIf

ElseIf cCampo == "M->GD4_IDEATI"
	If M->GD4_IDEATI == "0" .and. oGD4:aCols[oGD4:oBrowse:nAT,nGD4_IDPADR] == "LBTIK"
		HS_MsgInf(STR0012, STR0009, STR0030) //"Plano padrใo nใo pode ser desativado. Selecione outro plano padrใo antes de desativar o atual.""###"Atencao"###"Valida็ใo da digita็ใo"
		lRet := .f.
	ElseIf M->GD4_IDEATI == "1"
		If HS_IniPadR("GCM", 2, oGD4:aCols[oGD4:oBrowse:nAT,nGD4_CODPLA], "GCM_STATUS") == "0"
			HS_MsgInf(STR0049, STR0009, STR0030) //"Plano nใo pode ser ativado pois estแ desativado no Cadastro do Conv๊nio."###"Aten็ใo"###"Valida็ใo da digita็ใo"
			lRet := .F.
		EndIf
	Endif

ElseIf cCampo == "M->GD4_SQCATP"
	If !(lRet := HS_SeekRet("GFV", "oGD4:aCols[oGD4:oBrowse:nAT,nGD4_CODPLA] + M->GD4_SQCATP", 1, .F., "GD4_NMCATP", "GFV_NOMCAT",,, .T.))
		HS_MsgInf(STR0036 + oGD4:aCols[oGD4:oBrowse:nAT,nGD4_CODPLA] + STR0037, STR0009, STR0038) //"Categoria do Plano ["###"] nใo encontrada."###"Aten็ใo"###"Valida็ใo da Categoria"
	Endif

ElseIf 	(cCampo == "M->GBH_CEP" .Or. cCampo == "M->GBH_TEL" .Or. cCampo == "M->GBH_END" .Or. cCampo == "M->GBH_NUM" .Or. ;
         cCampo == "M->GBH_MUN" .Or. cCampo == "M->GBH_BAIRRO" .Or. cCampo == "M->GBH_COMPLE" .Or. cCampo == "M->GBH_EST" .Or. ;
          cCampo == "M->GBH_TELCOM") .And. !Inclui

	FS_EndGFD() //Sugere endereco do paciente para o responsavel caso ele seja menor de idade.

	If cCampo == "M->GBH_CEP" .And. GBH->GBH_CEP <> M->GBH_CEP
		M->GBH_NUM := Space(Len(GBH->GBH_NUM))
	EndIf

	If cCampo == "M->GBH_TEL" .Or. cCampo == "M->GBH_TELCOM"
		If Empty(SubStr(&(cCampo),1,2)) .Or. SubStr(&(cCampo),1,2) == "( "
			MsgStop(STR0064) //"Favor Informar o DDD do Telefone."
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "M->GBH_CEPCOM" .And. GBH->GBH_CEPCOM <> M->GBH_CEPCOM
	M->GBH_NUMCOM := Space(Len(GBH->GBH_NUMCOM))

ElseIf cCampo == "M->GBH_ESTCOM"
	If !(lRet := HS_SeekRet("SX5","'12' + M->GBH_ESTCOM", 1, .F.))
		HS_MsgInf(STR0048, STR0009, STR0030) //"Unidade Federativa nใo encontrada."###"Aten็ใo"###"Valida็ใo da digita็ใo"
	EndIf

ElseIf cCampo == "M->GBH_CODEMP"	/* Codigo da Empresa */
	If !Empty(M->GBH_CODEMP)
		If Empty(M->GBH_DESEMP := HS_IniPadr( "GAE", 1, M->GBH_CODEMP, "GAE_NOME",, .F.))
			HS_MsgInf(STR0032, STR0009, STR0030) //"C๓digo de nacionalidade invแlido."###"Aten็ใo"###"Valida็ใo da digita็ใo"
 			lRet := .F.
 		EndIf
 	Else
			M->GBH_DESEMP := ""
 	EndIf

ElseIf cCampo == "M->GFD_NOME"	/* Nome do Responsavel */
	If !Empty(M->GFD_NOME)
		FS_EndGFD(oGFD:oBrowse:nAt)
	EndIf

ElseIf cCampo == "M->GBH_CODNAC"
	HS_SeekRet("SX5","'34'+M->GBH_CODNAC",1,.F.,"GBH_DESNAC","X5_DESCRI")

ElseIf cCampo == "M->GBH_NOME"
	If SUBSTR(M->GBH_NOME, 1, 1) == " "
		HS_MsgInf(STR0044, STR0009, STR0030) //"Caraceter(es) iniciais em branco."###"Aten็ใo"###"Valida็ใo da digita็ใo"
		lRet := .F.
	EndIf

	If lRet
		For nCont := 1 to Len(Alltrim(M->GBH_NOME))
			If !(lRet := SUBSTR(M->GBH_NOME , nCont, 1) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ'- ")
				HS_MsgInf(STR0045 + SUBSTR(M->GBH_NOME , nCont, 1) + " ]", STR0009, STR0030) //"Caracter invแlido [ "###"Aten็ใo"###"Valida็ใo da digita็ใo"
				Exit
			EndIf
		Next
	EndIf

ElseIf cCampo == "M->GBH_PROFIS"
	If !(lRet := HS_SeekRet("GH1", "M->GBH_PROFIS", 1, .F., "GBH_DSPROF", "GH1_DESCBO",,, .T.))
		HS_MsgInf(STR0052, STR0009, STR0030) //"Ofํcio nใo encontrado"###"Aten็ใo"###"Valida็ใo da digita็ใo"
	Endif
ElseIf cCampo == "M->GFD_PROFIS"
	If !(lRet := HS_SeekRet("GH1", "M->GFD_PROFIS", 1, .F., "GFD_DSPROF", "GH1_DESCBO",,, .T.))
		HS_MsgInf(STR0052, STR0009, STR0030) //"Ofํcio nใo encontrado"###"Aten็ใo"###"Valida็ใo da digita็ใo"
	Endif
ElseIf cCampo == "M->GBH_CPF"
	lRet := Cgc(M->GBH_CPF)
	IF lEspelhar
		lRet := HS_VERBTS(3,M->GBH_CPF)
	Endif
ElseIf cCampo == "M->GBH_ORGEMI"
	If !Empty(Alltrim(M->GBH_ORGEMI)) .AND. !(lRet := HS_SeekRet("SX5","'64' + M->GBH_ORGEMI", 1, .F.))
		HS_MsgInf(STR0062, STR0009, STR0030) //"Orgใo Emissor nใo Cadastrado"###"Aten็ใo"###"Valida็ใo da digita็ใo"
	EndIf

ElseIf cCampo == "M->GBH_UFEMIS"
	If !Empty(Alltrim(M->GBH_UFEMIS)) .AND. !(lRet := HS_SeekRet("SX5","'12' + M->GBH_UFEMIS", 1, .F.))
		HS_MsgInf(STR0048, STR0009, STR0030) //"Unidade Federativa nใo encontrada."###"Aten็ใo"###"Valida็ใo da digita็ใo"
	EndIf

ElseIf cCampo == "M->GCY_ORGEMI"
	If !Empty(Alltrim(M->GCY_ORGEMI)) .AND. !(lRet := HS_SeekRet("SX5","'64' + M->GCY_ORGEMI", 1, .F.))
		HS_MsgInf(STR0062, STR0009, STR0030) //"Orgใo Emissor nใo Cadastrado"###"Aten็ใo"###"Valida็ใo da digita็ใo"
	EndIf

ElseIf cCampo == "M->GCY_UFEMIS"
	If !Empty(Alltrim(M->GCY_UFEMIS)) .AND. !(lRet := HS_SeekRet("SX5","'12' + M->GCY_UFEMIS", 1, .F.))
		HS_MsgInf(STR0048, STR0009, STR0030) //"Unidade Federativa nใo encontrada."###"Aten็ใo"###"Valida็ใo da digita็ใo"
	EndIf
ElseIf ReadVar() == "M->GTN_CODCRI"
	If !(lRet := HS_SeekRet("GTK", "M->GTN_CODCRI", 1, .F., "GTN_DESCRI", "GTK_DESCR") )
		HS_MsgInf(STR0067, STR0009, STR0068)  //"Critica nใo cadastrada" ### "Aten็ใo" ### "Valida็ใo de crํtica"
	EndIf
Endif
RestArea(aAreaOld)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_IncSa1 บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_IncSa1(nOpc)
Local nOpcAuto := nOpc, aCliente := {}
Local  aAreaOld := GetArea()
Local lRet   := .F.
Local lExDicCliOri  := HS_ExisDic({{"C", "GBH_CLIORI"}}, .F.)
Local lEspelhar := GetNewPar("MV_INTBTGB",.F.)
Local lAtuOri		:= .T.
Local cDDD := ""
Local cTel := ""
Local nTamTel := TamSx3("A1_TEL")[1]
Local cCodFor	:= ""
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

If nOpcAuto == 5 // Exclusใo
	If !FS_VldExc()
		RestArea(aAreaOld)
		Return(.F.)
	EndIf
EndIf

If ExistBlock("HSP58GCL")
	lGravaCli := Execblock("HSP58GCL",.F.,.F.,{lGravaCli})
EndIf

If nOpcAuto == 3 .AND. lGravaCli .and. !lEspelhar
	M->GBH_CODCLI := HS_VSxeNum("SA1", "M->A1_COD", 1)
	If lExDicCliOri  .AND. Empty(M->GBH_CLIORI)
		M->GBH_CLIORI := M->GBH_CODCLI
	EndIf
	M->GBH_LOJA := IIf(Empty(M->GBH_LOJA), '01', M->GBH_LOJA)
EndIf

If lExDicCliOri .and. !lEspelhar
	cCliExec := IIf(!eMPTY(M->GBH_CLIORI),M->GBH_CLIORI,M->GBH_CODCLI)
	If nOpcAuto == 4 .AND. Iif(!Empty(M->GBH_CLIORI), M->GBH_CLIORI <> M->GBH_CODCLI, .F.)
		lAtuOri	:= .F.
	EndIf
Else
	cCliExec := M->GBH_CODCLI
Endif
/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara pacientes de Convenio que sใo de Rede Propria (Integra็ใo PLS)           ณ
//ณnใo ้ realizada a altera็ใo na SA1 pois a familia possui o mesmo codigo de SA1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
If lAtuOri .AND. nOpcAuto == 4
	lAtuOri := !HS_VREDPRO(M->GBH_CODPAC)
EndIf

If (Inclui .or. (cAtuClie == "S")) .AND. lGravaCli  .AND. lAtuOri .and. !lEspelhar

	If Len(AllTrim(M->GBH_TEL)) >= 10
		cDDD := SubStr(Alltrim(M->GBH_TEL),1,2)
		cTel := SubStr(Alltrim(M->GBH_TEL),3,Len(Alltrim(M->GBH_TEL))-2)
	Else
		cTel := AllTrim(M->GBH_TEL)
	EndIf
	If Len(cTel) > nTamTel
		cTel := SubStr(cTel,1,nTamTel)
	EndIf

	aCliente := {	{"A1_FILIAL", xFilial("SA1"), NIL}, ;
					{"A1_NREDUZ", M->GBH_NOME   , NIL}, ;
					{"A1_TIPO"  , "F"           , NIL}, ;
					{"A1_COD"   , cCliExec 		, NIL}, ;
					{"A1_LOJA"  , M->GBH_LOJA   , NIL}, ;
					{"A1_CLICNV", "0"           , NIL}, ;
					{"A1_NOME"  , M->GBH_NOME   , NIL}, ;
					{"A1_DTNASC", M->GBH_DTNASC , NIL}, ;
					{"A1_END"   , AllTrim(M->GBH_END) +", " + AllTrim(M->GBH_NUM), NIL}, ;
					{"A1_EST"   , M->GBH_EST    , NIL}, ;
					{"A1_MUN"   , M->GBH_MUN    , NIL}, ;
					{"A1_BAIRRO", M->GBH_BAIRRO , NIL}, ;
					{"A1_CEP"   , M->GBH_CEP    , NIL}, ;
					{"A1_DDD"	, cDDD, NIL}, ;
					{"A1_TEL"   , cTel, NIL}, ;
					{"A1_PESSOA", "F"           , NIL}, ;
					{"A1_CGC"   , M->GBH_CPF    , NIL}, ;
					{"A1_RG"    , M->GBH_RG     , NIL}, ;
					{"A1_PFISICA", IIF(!Empty(Alltrim(M->GBH_RG)), M->GBH_RG+M->GBH_ORGEMI,Space(Len(SA1->A1_PFISICA))), NIL}}
	If Inclui
		aAdd(aCliente,{"A1_ENDCOB"   , AllTrim(M->GBH_END) +", " + AllTrim(M->GBH_NUM), NIL})
		aAdd(aCliente,{"A1_ENDENT"   , AllTrim(M->GBH_END) +", " + AllTrim(M->GBH_NUM), NIL})
		aAdd(aCliente,{"A1_ENDREC"   , AllTrim(M->GBH_END) +", " + AllTrim(M->GBH_NUM), NIL})
	EndIf
	Begin Transaction
		MSExecAuto({|X, Y| Mata030(X, Y)}, aCliente, nOpcAuto)
		If lMsErroAuto
			If nOpcAuto == 3
				RollBackSx8()
			EndIf
			DisarmTransaction()
		EndIf

		If lMsErroAuto
			Mostraerro()
			lRet := .F.
		Else
			If nOpcAuto == 3
				ConfirmSx8()
			EndIf

			M->GBH_CODCLI := SA1->A1_COD
			If lExDicCliOri .AND. Empty(M->GBH_CLIORI)
				M->GBH_CLIORI := M->GBH_CODCLI
			EndIf
			M->GBH_LOJA   := SA1->A1_LOJA

			lRet := .T.
		EndIf
	End Transaction
ElseIf !(lGravaCli) .and. !lEspelhar
	M->GBH_CODCLI	:= cCliente
	If lExDicCliOri .AND. Empty(M->GBH_CLIORI)
		M->GBH_CLIORI := M->GBH_CODCLI
	EndIf
	M->GBH_LOJA		:= cLojCli
	If ExistBlock("HSP58GCL")
		lGravaCli := Execblock("HSP58GCL",.F.,.F.,{lGravaCli})

 	Else
		lGravaCli		:= .T.

 	EndIf
	lRet := .T.

Else
	lRet := .T.
EndIf

cCliente	:= ""
cLojCli		:= ""

// INCLUI FORNECEDOR SA2 ==================================
If nOpcAuto == 3 .AND. lGravaCli .and. !lEspelhar
	cCodFor := HS_GFornPac(M->GBH_CODPAC, M->GBH_CODCLI)
	If !Empty(cCodFor)
		M->GBH_CODFOR := cCodFor 
	EndIF
EndIf

RestArea(aAreaOld)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldExc บAutor  ณLuiz Pereira S. Jr. บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz as validacoes de exclusao de prontuario.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

 Function FS_VldExc(cCodPac)
 Local aArea := GetArea()
 Local lRet   := .T.
 Default cCodPac:= M->GBH_CODPAC

 DbSelectArea("GCY")
 DbSetOrder(2) // GCY_FILIAL + GCY_REGGER
 If DbSeek(xFilial("GCY") + cCodPac)
  HS_MsgInf(STR0010, STR0009, STR0006) //"Exclusใo nใo permitida. Paciente com Atendimento."###"Atencao"###"Excluir"
  Return(.F.)
 Else
  DbSelectArea("GM8")
  DbSetOrder(10) // GM8_FILIAL+GM8_REGGER+GM8_CODPRO+DTOS(GM8_DATAGE)+GM8_STATUS
  DbSeek(xFilial("GM8") + cCodPac)
  While xFilial("GM8") == GM8->GM8_FILIAL .And. cCodPac == GM8->GM8_REGGER .And. lRet
   If GM8->GM8_DATAGE >=dDatabase .And. GM8->GM8_STATUS $ "1#3#4#5"
    HS_MsgInf(STR0034, STR0009, STR0006) //"Exclusใo nใo permitida. Paciente com agenda ambulatorial marcada."###"Atencao"###"Excluir"
    RestArea(aArea)
    Return(.F.)
   EndIf
   DbSkip()
  End

  DbSelectArea("GMJ")
  DbSetOrder(5) //GMJ_FILIAL+GMJ_REGGER+DTOS(GMJ_DATAGE)+GMJ_CODPRO
  If DbSeek(xFilial("GMJ") + cCodPac)
   HS_MsgInf(STR0035, STR0009, STR0006) //"Exclusใo nใo permitida. Paciente com reserva cir๚rgica."###"Aten็ใo"###"Excluir"
   RestArea(aArea)
   Return(.F.)
  EndIf
 EndIf

 RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TudoOK บ Autor ณ Cibele Peria       บ Data ณ  17/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verificacao de validade da confirmacao de atualizacao      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_TudoOK(oOK,nPos)
Local lRet := .T., nForACols := 0, lAchou := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada - HSP58OK1               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("HSP58OK1")
	lRet := ExecBlock("HSP58OK1", .F., .F.)
	If !lRet
		Return(lRet)
	EndIf
EndIf

If !(lRet := Len(oOK:aCols) == 1 .And. Empty(oOK:aCols[1,nPos])) .And. (lRet := oOk:TudoOK())

	For nForaCols := 1 to len(oOK:aCols)
		If oOK:aCols[nForACols,IIF(oOK = oGD4,nGD4_IDPADR, nGFD_IDPADR)] == "LBTIK"
			lAchou := .T.
			Exit
		Endif
	Next

	If !lAchou
		If oOK == oGD4
			HS_MsgInf(STR0011, STR0009, STR0001) //"Por favor, marque o plano padrใo do paciente!"###"Aten็ใo"###"Cadastro de paciente"
		ElseIf oOk == oGFD
			HS_MsgInf(STR0024, STR0009, STR0001) //"Por favor, marque o responsแvel padrใo do paciente!"###"Aten็ใo"###"Cadastro de paciente"
		EndIf
		lRet := .F.
	Endif

	If lRet .And. oOK == oGD4
		For nForaCols := 1 to len(oOK:aCols)
			If !oOK:aCols[nForaCols, Len(oOK:aCols[nForaCols])]
				If oOK:aCols[nForaCols, nGD4_IDEATI] == "1" .And. HS_IniPadR("GCM", 2, oOK:aCols[nForaCols, nGD4_CODPLA], "GCM_STATUS") == "0"
					HS_MsgInf(STR0050 + oOK:aCols[nForaCols, nGD4_CODPLA] + STR0051, STR0009, STR0030) //"Plano ["###"] nใo pode ser ativado pois estแ inativo no Cadastro do Conv๊nio."###"Aten็ใo"###"Valida็ใo da digita็ใo"
					lRet := .F.
					Exit
				Endif
			EndIf
		Next
	EndIf

Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MPlan บ Autor ณ Cibele Peria       บ Data ณ  21/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca plano padrao do paciente                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(nMar)
Local nForACols := 0

If oGD4:aHeader[oGD4:oBrowse:nColPos, 2] == "GD4_IDPADR" .and. !oGD4:aCols[nMar,nUGD4+1] .and. oGD4:aCols[nMar,nGD4_IDEATI] == "1"
	If oGD4:aCols[nMar,nGD4_IDPadr] == "LBNO"
		oGD4:aCols[nMar,nGD4_IDPadr] := "LBTIK"
		For nForACols := 1 to len(oGD4:aCols)
			If oGD4:aCols[nForACols,nGD4_IDPadr] == "LBTIK" .And. nForACols <> nMar
				oGD4:aCols[nForACols,nGD4_IDPadr] := "LBNO"
				Exit
			Endif
		Next
	Endif
ElseIf oGD4:aHeader[oGD4:oBrowse:nColPos, 2] == "GD4_IDDOAC" .and. !oGD4:aCols[nMar,nUGD4+1]
	If oGD4:aCols[nMar,nGD4_IDDoac] == "LBNO"
		oGD4:aCols[nMar,nGD4_IDDoac] := "LBTIK"
		For nForACols := 1 to len(oGD4:aCols)
			If oGD4:aCols[nForACols,nGD4_IDDoac] == "LBTIK" .And. nForACols <> nMar
				oGD4:aCols[nForACols,nGD4_IDDoac] := "LBNO"
				Exit
			Endif
		Next
	Endif
ElseIf oGD4:aHeader[oGD4:oBrowse:nColPos, 2] == "GD4_IDPADR" .and. !oGD4:aCols[nMar,nUGD4+1] .and. oGD4:aCols[nMar,nGD4_IDEATI] == "0" 
	HS_MsgInf(STR0012, STR0009, STR0030) //"Plano padrใo nใo pode ser desativado. Selecione outro plano padrใo antes de desativar o atual.""###"Atencao"###"Valida็ใo da digita็ใo"
Else
	oGD4:EDITCELL( oGD4:OBROWSE, oGD4:oBrowse:nAt, oGD4:oBrowse:nColPos )
	
EndIf
oGD4:oBrowse:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_NovLinบ Autor ณ Cibele Peria       บ Data ณ  29/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera nova linha no browse                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_NovLin()
oGD4:lChgField := .F.
oGD4:AddLine()
oGD4:aCols[len(oGD4:aCols), nGd4_IdPadr] := IIF(len(oGD4:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado
oGD4:aCols[len(oGD4:aCols), nGd4_IdDoac] := IIF(len(oGD4:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_NovLinRบ Autor ณ Daniel Peixoto    บ Data ณ  20/09/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera nova linha no browse                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_NovLinR()
oGFD:lChgField := .F.
oGFD:AddLine()
oGFD:aCols[len(oGFD:aCols), nGfd_IdPadr] := IIF(len(oGFD:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VldDelบ Autor ณ Cibele Peria       บ Data ณ  11/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida exclusao de uma linha                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldDel(Alias)
Local lRet := .T.

If Alias == "GD4"
	If oGD4:aCols[oGD4:oBrowse:nAt,nGD4_IDPadr] == "LBTIK"
		HS_MsgInf(STR0013, STR0009, STR0006) //"Plano padrใo nใo pode ser excluํdo. Selecione outro plano padrใo antes de excluir o atual."###"Aten็ใo"###"Excluir"
		lRet := .F.
	ElseIf !oGD4:aCols[oGD4:oBrowse:nAt,nUGD4+1]
		DbSelectArea("GCZ")
		DbSetOrder(13) // GCZ_FILIAL + GCZ_CODPLA + GCZ_REGGER
		If DbSeek(xFilial("GCZ") +  oGD4:aCols[oGD4:oBrowse:nAt,nGD4_CodPla] + M->GBH_CODPAC)
			HS_MsgInf(STR0018, STR0009, STR0001) //"Plano jแ utilizado em atendimento do paciente. Exclusใo nใo permitida!"###"Aten็ใo"###"Cadastro de paciente"
			lRet := .F.
		Endif
	Endif

ElseIf Alias == "GFD"
	If oGFD:aCols[oGFD:oBrowse:nAt,nGFD_IDPadr] == "LBTIK"
		HS_MsgInf(STR0025, STR0009, STR0001) //"Responsแvel padrใo nใo pode ser excluํdo. Selecione outro responsแvel padrใo antes de excluir o atual."###"Aten็ใo"###"Cadastro de paciente"
		lRet := .F.
	ElseIf !FS_ValId()
		lRet := .F.
	EndIf

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_A58EXT ณ Autor ณ Robson Ramiro A. Oliveณ Data ณ 17.03.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Extrato do paciente                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ HS_M39EXT                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A58EXT(cAlias, nReg, nOpc)

HS_EXTM24C(GBH->GBH_CODPAC, "", nOpc)

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_GrvGF1 ณ Autor ณ MARCELO JOSE          ณ Data ณ 13.06.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ GRAVA ARQUIVO DE TELEFONES DO PACIENTE NEWGETDADOS FOLDER 2ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGF1()
Local   nItem 				:= 0
Local   cAliasOld := Alias(), lAchou := .F.

For nItem := 1 To Len(oGF1:aCols)
	DbSelectArea("GF1")
	DbSetOrder(1) // GF1_FILIAL + GF1_REGGER + GF1_SEQFON
	lAchou := !Empty(oGF1:aCols[nItem, nGF1_SeqFon]) .And. DbSeek(xFilial("GF1") + M->GBH_CODPAC + oGF1:aCols[nItem, nGF1_SeqFon])
	If oGF1:aCols[nItem, Len(oGF1:aCols[nItem])] .And. lAchou /* exclusao */
		RecLock("GF1", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("GF1")
	Else
		If !lAchou
			M->GF1_SEQFON := GetSXENum("GF1", "GF1_SEQFON")
			M->GF1_SEQFON := HS_VSxeNum("GF1", "M->GF1_SEQFON", 1)
			ConfirmSX8()
		Else
			M->GF1_SEQFON := oGF1:aCols[nItem, nGF1_SeqFon]
		EndIf

		RecLock("GF1", !lAchou)
		HS_GRVCPO("GF1", oGF1:aCols, oGF1:aHeader, nItem)
		GF1->GF1_FILIAL := xFilial("GF1")
		GF1->GF1_SEQFON := M->GF1_SEQFON
		GF1->GF1_REGGER := M->GBH_CODPAC
		GF1->GF1_LOGARQ := HS_LogArq()
		MsUnlock()
	EndIf
Next

DbSelectArea(cAliasOld)
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      chama etiqueta da DO CADASTRO DE PACIENTE                          ฑฑ
ฑฑ      MARCELO JOSE                                       30/08/2005      ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//*** ATENCAO ESTA ETIQUETA EH PARA OS GBH - CADASTRO DE PACIENTES
FUNCTION HS_ETQPACI()
Local cNomeEtq := ALLTRIM(GETMV("MV_ETIQPAC"))
IF !Empty(cNomeEtq)
	/* 1o. parametro nome da etiqueta*/
	/* 2o. parametro matriz com: 1=qtde de cada etiq. parametro pergunta de/ate */
	HSPAHR71(cNomeEtq,{1,GBH->GBH_CODPAC,GBH->GBH_CODPAC},.T. )
Else
	HS_MsgInf(STR0026, STR0009, STR0001)   //"O nome da etiqueta nใo estแ informado no parโmetro MV_ETIQPAC...Opera็ใo cancelada."###"Aten็ใo"###"Cadastro de paciente"
EndIf
Return(Nil)

// Calculo da idade do paciente
Function HS_A58Age(dNasc,dRefer)
Local aAge := "", cRetAge := ""

Default dNasc   := M->GBH_DTNASC
Default dRefer  := DDATABASE

aAge    := HS_DIFDATA(dNasc, dRefer)

cRetAge := Str(aAge[1], 3, 0) + STR0027 + Str(aAge[2], 2, 0) + "m" + Str(aAge[3], 2, 0) + "d" //"a"

Return(cRetAge)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DuplA58บ Autor ณ Cibele Peria       บ Data ณ  01/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o duplicidade de ocorrencia nas getdados            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DuplA58()
Local nPosDupl := 0
Local lRet     := .T.

If Empty(&(ReadVar()))
	Return(.T.)
Endif

If ReadVar() == "M->GD4_CODPLA"
	If (nPosDupl := aScan(oGD4:aCols, {| aVet | aVet[nGD4_CODPLA] == M->GD4_CODPLA}) ) <> oGD4:nAt .and. nPosDupl <> 0
		HS_MsgInf(STR0019 + ALLTRIM(STR(nPosDupl)) + ".", STR0009, STR0001) //"Informa็ใo jแ cadastrada. Por favor, verifique a linha."###"Aten็ใo"###"Cadastro de paciente"
		lRet := .F.
	Endif
	cGFVPlano := M->GD4_CODPLA
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_GrvGFD ณ Autor ณ MARCELO JOSE          ณ Data ณ 16.09.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ GRAVA ARQUIVO DE RESPONSAVEIS DO PACIENTE  FOLDER 3        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAHSP                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGFD()
Local   nItem 				:= 0
Local   cAliasOld := Alias(), lAchou := .F.

For nItem := 1 To Len(oGFD:aCols)
	DbSelectArea("GFD")
	DbSetOrder(1) // GFD_FILIAL + GFD_SEQRES
	lAchou := !Empty(oGFD:aCols[nItem, nGFD_SeqRes]) .And. DbSeek(xFilial("GFD") + oGFD:aCols[nItem, nGFD_SeqRes])
	If oGFD:aCols[nItem, Len(oGFD:aCols[nItem])] .And. lAchou /* exclusao */
		RecLock("GFD", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("GFD")
	Else
		If !Empty(oGFD:aCols[nItem, nGFD_Nome])
			If !lAchou
				M->GFD_SEQRES := HS_VSxeNum("GFD", "M->GFD_SEQRES", 1)
			Else
				M->GFD_SEQRES := oGFD:aCols[nItem, nGFD_SEQRES]
			EndIf

			RecLock("GFD", !lAchou)
			HS_GRVCPO("GFD", oGFD:aCols, oGFD:aHeader, nItem)
			GFD->GFD_FILIAL := xFilial("GFD")
			GFD->GFD_IDPADR := IIf(oGFD:aCols[nItem,nGFD_IDPADR] == "LBNO","0","1")
			GFD->GFD_SEQRES := M->GFD_SEQRES
			GFD->GFD_REGGER := M->GBH_CODPAC
			GFD->GFD_LOGARQ := HS_LogArq()
			MsUnlock()
		EndIf
	EndIf
Next

DbSelectArea(cAliasOld)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_ResDbc บ Autor ณ Cibele Peria       บ Data ณ  21/12/04  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca Responsavel pelo paciente                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ResDbC(nMar)
Local nForACols := 0

If oGFD:aHeader[oGFD:oBrowse:nColPos, 2] == "GFD_IDPADR" .and. !oGFD:aCols[nMar,nUGFD+1]
	If oGFD:aCols[nMar,nGFD_IDPadr] == "LBNO"
		oGFD:aCols[nMar,nGFD_IDPadr] := "LBTIK"
		For nForACols := 1 to len(oGFD:aCols)
			If oGFD:aCols[nForACols,nGFD_IDPadr] == "LBTIK" .And. nForACols <> nMar
				oGFD:aCols[nForACols,nGFD_IDPadr] := "LBNO"
				Exit
			Endif
		Next
	Endif
Else
	oGFD:EDITCELL( oGFD:OBROWSE, oGFD:oBrowse:nAt, oGFD:oBrowse:nColPos )
EndIf
oGFD:oBrowse:Refresh()

Return()

Function FS_RetCpos(cAlias)
Local lRet := .F.

If ReadVar() == "M->GBH_CEP" .OR. ReadVar() == "M->GFD_CEP"
	If(GBH->(FieldPos("GBH_TIPLOG"))) > 0
		lRet := HS_SeekRet("GAM","M->"+cAlias+"_CEP",3,.F.,{cAlias+"_MUN",cAlias+"_EST",cAlias+"_END",cAlias+"_BAIRRO",cAlias+"_TIPLOG"},{"GAM_MUNICI","GAM_EST","GAM_END","GAM_BAIRRO","GAM_TIPLOG"})
	Else
		lRet := HS_SeekRet("GAM","M->"+cAlias+"_CEP",3,.F.,{cAlias+"_MUN",cAlias+"_EST",cAlias+"_END",cAlias+"_BAIRRO"},{"GAM_MUNICI","GAM_EST","GAM_END","GAM_BAIRRO"})
	EndIf
ElseIf ReadVar() == "M->GBH_CEPCOM"
	lRet := HS_SeekRet("GAM","M->"+cAlias+"_CEPCOM",3,.F.,{cAlias+"_MUNCOM",cAlias+"_ESTCOM",cAlias+"_ENDCOM",cAlias+"_BAICOM"},{"GAM_MUNICI","GAM_EST","GAM_END","GAM_BAIRRO"})
EndIf

Return(lRet)

/*/
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PlanoOKบ Autor ณ Cibele Peria       บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consiste se a digitacao do plano foi OK.                   บฑฑ
ฑฑบ          ณ Se o convenio do plano informado nao for do tipo particu - บฑฑ
ฑฑบ          ณ lar, a digitacao do codigo da carteirinha (matricula) eh   บฑฑ
ฑฑบ          ณ obrigatoria.                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_PlanoOK()
Local aArea := GetArea()
Local lRet := .T.
LOCAL nPosT	:= aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_SNTITU"})
LOCAL nPosR	:= aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_REGTIT"})//add
LOCAL nPosN	:= aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_NOMTI1"})//add

If Empty(oGD4:aCols[oGD4:oBrowse:nAt, nGD4_MATRIC])
	DbSelectArea("GCM")
	DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
	DbSeek(xFilial("GCM") + oGD4:aCols[oGD4:oBrowse:nAt, nGD4_CODPLA])

	DbSelectArea("GA9")
	DbSetOrder(1) // GA9_FILIAL + GA9_CODCON
	DbSeek(xFilial("GA9") + GCM->GCM_CODCON)

	If GA9->GA9_TIPCON == "0" //Convenio nao particular
		HS_MsgInf(STR0029, STR0009, STR0001) //"Por favor, informe o n๚mero da carteirinha do paciente!"###"Aten็ใo"###"Cadastro de paciente"
		lRet := .F.
	Endif
Endif

If Empty(oGD4:aCols[oGD4:oBrowse:nAt, nPosR])
	oGD4:aCols[oGD4:oBrowse:nAt, nPosT] := "S"
EndIf

RestArea(aArea)

Return(lRet)

/*/
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DTVALI บ Autor ณ MARIO ARIZONO      บ Data ณ  11/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDA DATA DE VALIDADE DE ACORDO COM O TIPO DE CONVENIO.  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DTVALI()
Local lRet := .T.
Local aArea := GetArea()

If !EMPTY(oGD4:aCols[oGD4:oBrowse:nAT,nGD4_CODPLA])
	DbSelectArea("GCM")
	DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
	If DbSeek(xFilial("GCM") + oGD4:aCols[oGD4:oBrowse:nAT,nGD4_CODPLA])
		DbSelectArea("GA9")
		DbSetOrder(1) //GA9_FILIAL + GA9_CODCON
		If Dbseek(xFilial("GA9") + GCM->GCM_CODCON)
			If GA9->GA9_TIPCON == "1"
				lRet := .F.
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
ฑฑบPrograma  ณFS_EndGFD บAutor  ณEduardo Alves       บ Data ณ  05/22/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfere se o Paciente e menor de idade, em caso positivo,   บฑฑ
ฑฑบ          ณPreenche o endereco do responsavel igual do paciente.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_EndGFD(nLinG)
If VAL(SUBSTR(M->GBH_IDADE,1,3)) <= 18
	If nLinG # Nil 	/* Processado quando Digitado o nome do Responsavel */
		oGFD:aCols[nLinG,nGFD_End]   := M->GBH_END
		oGFD:aCols[nLinG,nGFD_Tel]   := M->GBH_TEL
		oGFD:aCols[nLinG,nGFD_Cep]   := M->GBH_CEP
		oGFD:aCols[nLinG,nGFD_Mun]   := M->GBH_MUN
		oGFD:aCols[nLinG,nGFD_Num]   := M->GBH_NUM
		oGFD:aCols[nLinG,nGFD_Bairro]:= M->GBH_BAIRRO
		oGFD:aCols[nLinG,nGFD_Est]   := M->GBH_EST
		oGFD:aCols[nLinG,nGFD_Com]   := M->GBH_COMPLE

	Else 									/* Processado quando Alterado o endereco do Paciente */

		/* Verifica se o Endereco do Responsaval e igual ao do paciente, se for ele altera conforme o do paciente, caso contrario fica do mesmo jeito */
		For nLinG := 1 To Len(oGFD:aCols)
			oGFD:aCols[nLinG,nGFD_End]   := IIf(oGFD:aCols[nLinG,nGFD_End] 			== cGBH_END 				.Or. Empty(oGFD:aCols[nLinG,nGFD_End]), 			M->GBH_END, 				oGFD:aCols[nLinG,nGFD_End])
			oGFD:aCols[nLinG,nGFD_Tel]   := IIf(oGFD:aCols[nLinG,nGFD_Tel] 			== cGBH_TEL 				.Or. Empty(oGFD:aCols[nLinG,nGFD_Tel]), 			M->GBH_TEL, 				oGFD:aCols[nLinG,nGFD_Tel])
			oGFD:aCols[nLinG,nGFD_Cep]   := IIf(oGFD:aCols[nLinG,nGFD_Cep] 			== cGBH_CEP 				.Or. Empty(oGFD:aCols[nLinG,nGFD_Cep]), 			M->GBH_CEP, 				oGFD:aCols[nLinG,nGFD_Cep])
			oGFD:aCols[nLinG,nGFD_Mun]   := IIf(oGFD:aCols[nLinG,nGFD_Mun] 			== cGBH_MUN 				.Or. Empty(oGFD:aCols[nLinG,nGFD_Mun]), 			M->GBH_MUN, 				oGFD:aCols[nLinG,nGFD_Mun])
			oGFD:aCols[nLinG,nGFD_Num]   := IIf(oGFD:aCols[nLinG,nGFD_Num]	 		== cGBH_NUM 				.Or. Empty(oGFD:aCols[nLinG,nGFD_Num]), 			M->GBH_NUM, 				oGFD:aCols[nLinG,nGFD_Num])
			oGFD:aCols[nLinG,nGFD_Bairro]:= IIf(oGFD:aCols[nLinG,nGFD_Bairro]	== cGBH_BAIRRO 	.Or. Empty(oGFD:aCols[nLinG,nGFD_Bairro]),	M->GBH_BAIRRO, 	oGFD:aCols[nLinG,nGFD_Bairro])
			oGFD:aCols[nLinG,nGFD_Est]   := IIf(oGFD:aCols[nLinG,nGFD_Est]	 		== cGBH_EST 				.Or. Empty(oGFD:aCols[nLinG,nGFD_Est]), 			M->GBH_EST,					oGFD:aCols[nLinG,nGFD_Est])
			oGFD:aCols[nLinG,nGFD_Com]   := IIf(oGFD:aCols[nLinG,nGFD_Com] 			== cGBH_COMPLE 	.Or. Empty(oGFD:aCols[nLinG,nGFD_Com]), 			M->GBH_COMPLE,	 oGFD:aCols[nLinG,nGFD_Com])
		Next nLinG

	EndIf
	oGFD:oBrowse:Refresh()
EndIf
Return

Static Function FS_SetaPla()

cGFVPlano := oGD4:aCols[oGD4:oBrowse:nAt, nGD4_CODPLA]

Return(Nil)

Static Function FS_VldOkCPF()
Local aAreaOld := GetArea()
Local lRet := .T.

If !FS_VerRG()
	Return(.F.)
EndIf

If Inclui .And. lRet
	If !(lRet := FS_VldCPF(M->GBH_CPF))
		If !MsgYesNo(STR0063)
			HS_MsgInf(STR0039, STR0009, STR0040) //"Nใo ้ possํvel cadastrar o cliente. Jแ existe cliente cadastrado com o CPF informado."###"Aten็ใo"###"Cadastro de Cliente"
		Else
			lRet := .T.
			lGravaCli := .F.
		EndIf
	Else
		If !Empty(M->GBH_RG)
			DbSelectArea("GBH")  //Verifica na Inclusao se ja existe cadastro com o mesmo Nr. RG+Data de Nascimento
			DbSetOrder(4) // GBH_FILIAL + GBH_RG + GBH_DATNASC
			If dbseek(xFilial("GBH") + M->GBH_RG + DTOS(M->GBH_DTNASC))
				If !MsgYesNo(STR0016 + GBH->GBH_CODPAC + "-" + AllTrim(GBH->GBH_NOME) + " " + STR0017)//"Jแ existe Cadastro com o mesmo RG e Data de Nascimento com o prontuแrio: "###"  Deseja Continuar?"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf Altera .And. lRet
	If !(lRet := FS_VldCPF(M->GBH_CPF, M->GBH_CODCLI, .T.))
		HS_MsgInf(STR0041, STR0009,STR0043) //"Nใo ้ possํvel alterar o cliente. Jแ existe cliente cadastrado com o CPF informado."###"Aten็ใo"###"Cadastro de Cliente"
	EndIf
EndIf

RestArea(aAreaOld)

Return(lRet)

Static Function FS_VldCPF(cCPF, cCodCli, lAltera)
Local aAreaOld := GetArea()
Local lRet := .T.

Default lAltera := .F.

If !EMPTY(cCPF)
	DbSelectArea("SA1")
	DbSetOrder(3) // A1_FILIAL + A1_CGC
	If DbSeek(xFilial("SA1") + cCPF) .And. IIF(lAltera, SA1->A1_COD <> cCodCli, .T.) .And. cAtuClie == "S"
		cCliente	:= SA1->A1_COD
		cLojCli		:= SA1->A1_LOJA
		lRet 		:= .F.
	EndIf
EndIf

RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VerRG บAutor  ณPatricia Queiroz     บ Data ณ  07/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o RG e orgao emissor cadastrado jแ existe na base.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VerRG()

Local aArea := GetArea()
Local lRet  := .T.

DbSelectArea("GBH")
DbSetOrder(6) //GBH_FILIAL + GBH_RG + GBH_ORGEMI + GBH_UFEMIS
If !Empty(M->GBH_RG) .And. !Empty(M->GBH_ORGEMI) .And. !Empty(M->GBH_UFEMIS)
	If DbSeek(xFilial("GBH") + M->GBH_RG + M->GBH_ORGEMI + M->GBH_UFEMIS) .And. IIF(Altera .OR. Inclui, GBH->GBH_CODPAC <> M->GBH_CODPAC, .F.)
		HS_MsgInf(STR0046, STR0009, STR0047) //"Jแ existe registro cadastrado com mesmo RG e ๓rgใo emissor."###"Aten็ใo"###"Valida็ใo do RG"
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

Static Function FS_AtuPac()
Local cConcat := Iif(TcGetDb() = "MSSQL"," + "," || ")
Local cSql    := ""
Local lAtuNome := .F.

aArea:=GetArea()

lAtuNome := GBH->GBH_NOME <> M->GBH_NOME

If (GBH->GBH_DTNASC <> M->GBH_DTNASC)

	DbSelectArea("GCY")
	DbSetOrder(2) // GCY_FILIAL + GCY_REGGER + GCY_TPALTA
	DbSeek(xFilial("GCY") + M->GBH_CODPAC)
	While !Eof() .And. GCY->GCY_REGGER == M->GBH_CODPAC
		RecLock("GCY", .F.)
		If lAtuNome
			GCY->GCY_NOME := M->GBH_NOME
		EndIf
		GCY->GCY_DTNASC := M->GBH_DTNASC
		GCY->GCY_IDADE  := HS_A58AGE(M->GBH_DTNASC, GCY_DATATE)
		MsUnLock()
		DbSkip()
	End

ElseIf lAtuNome
	TcSqlExec("UPDATE " + RetSqlName("GCY") + " SET GCY_NOME = '" + M->GBH_NOME + "' WHERE GCY_REGGER = '"+M->GBH_CODPAC+ "' AND GCY_FILIAL = '" + xFilial("GCY") + "' AND D_E_L_E_T_ <> '*'")
EndIf

If !lAtuNome
	Return(nil)
EndIf

TcSqlExec("UPDATE "+RetSqlName("GCZ")+" SET GCZ_NOME = '"+M->GBH_NOME+"' WHERE GCZ_REGGER = '"+M->GBH_CODPAC+ "' AND GCZ_FILIAL = '" + xFilial("GCZ") + "'  AND D_E_L_E_T_ <> '*'")

//Replica altera็ใo no nome do Paciente para todas tabelas afins.
TcSqlExec("UPDATE " + RetSqlName("GBY") + " SET GBY_NOMPAC = '" + M->GBH_NOME + "' WHERE GBY_REGATE IN (SELECT GCY_REGATE FROM " + RetSqlName("GCY") + " WHERE GCY_REGGER = '" + M->GBH_CODPAC + "') AND GBY_FILIAL = '" + xFilial("GBY") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GM8") + " SET GM8_NOMPAC = '" + M->GBH_NOME + "' WHERE GM8_REGGER = '" + M->GBH_CODPAC + "' AND GM8_FILIAL = '" + xFilial("GM8") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GM9") + " SET GM9_NOMPAC = '" + M->GBH_NOME + "' WHERE GM9_REGGER = '" + M->GBH_CODPAC + "' AND GM9_FILIAL = '" + xFilial("GM9") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GMA") + " SET GMA_NOMPAC = '" + M->GBH_NOME + "' WHERE GMA_REGGER = '" + M->GBH_CODPAC + "' AND GMA_FILIAL = '" + xFilial("GMA") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GMJ") + " SET GMJ_NOMPAC = '" + M->GBH_NOME + "' WHERE GMJ_REGGER = '" + M->GBH_CODPAC + "' AND GMJ_FILIAL = '" + xFilial("GMJ") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GML") + " SET GML_NOMPAC = '" + M->GBH_NOME + "' WHERE GML_REGGER = '" + M->GBH_CODPAC + "' AND GML_FILIAL = '" + xFilial("GML") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GMM") + " SET GMM_NOMPAC = '" + M->GBH_NOME + "' WHERE GMM_REGGER = '" + M->GBH_CODPAC + "' AND GMM_FILIAL = '" + xFilial("GMM") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GSE") + " SET GSE_NOMPAC = '" + M->GBH_NOME + "' WHERE GSE_REGGER = '" + M->GBH_CODPAC + "' AND GSE_FILIAL = '" + xFilial("GSE") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GSA") + " SET GSA_NOMPAC = '" + M->GBH_NOME + "' WHERE GSA_REGGER = '" + M->GBH_CODPAC + "' AND GSA_FILIAL = '" + xFilial("GSA") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GO0") + " SET GO0_NOMPAC = '" + M->GBH_NOME + "' WHERE GO0_REGGER = '" + M->GBH_CODPAC + "' AND GO0_FILIAL = '" + xFilial("GO0") + "' AND D_E_L_E_T_ <> '*'")
TcSqlExec("UPDATE " + RetSqlName("GAI") + " SET GAI_NOMPAC = '" + SUBSTR(M->GBH_NOME,1,LEN(GAI->GAI_NOMPAC)) + "' WHERE GAI_FILIAL = '" + xFilial("GAI") + "' AND D_E_L_E_T_ <> '*' AND GAI_REGATE IN (SELECT GCY_REGATE FROM " + RetSqlName("GCY") + " WHERE GCY_REGGER = '" + M->GBH_CODPAC + "') AND GAI_NOMPAC =  '" + SUBSTR(GBH->GBH_NOME,1,LEN(GAI->GAI_NOMPAC)) + "'")
TcSqlExec("UPDATE " + RetSqlName("GAV") + " SET GAV_NOME = '" + M->GBH_NOME + "' WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND D_E_L_E_T_ <> '*' AND GAV_REGGER = '" + M->GBH_CODPAC + "' AND GAV_RESERV NOT IN ( '0', '1', '2', '3', '4', '5')")
TcSqlExec("UPDATE " + RetSqlName("GD4") + " SET GD4_NOMTIT = '" + M->GBH_NOME + "' WHERE GD4_REGGER = '" + M->GBH_CODPAC + "' AND GD4_NOMTIT = (SELECT GBH_NOME FROM "+ RetSqlName("GBH") +" WHERE GBH_FILIAL = '" + xFilial("GD4") + "' AND GBH_CODPAC = '"+ M->GBH_CODPAC +"') AND GD4_FILIAL = '" + xFilial("GD4") + "' AND D_E_L_E_T_ <> '*'")

//Replica altera็ใo no nome do Paciente para todas tabelas que possuem o nome do RN
cSql := " UPDATE " + RetSqlName("GB2")
cSql += "    SET GB2_NOME = '" + "RN "+ SUBSTR(M->GBH_NOME,1,TAMSX3("GB2_NOME")[1] - 3) + "' , GB2_MAE = '"+ M->GBH_NOME +"' "
cSql += "  WHERE GB2_REGATE IN (SELECT GCY_REGATE "
cSql += "                         FROM " + RetSqlName("GCY")
cSql += "                        WHERE GCY_REGGER = '" + M->GBH_CODPAC + "')"
cSql += "    AND GB2_FILIAL = '" + xFilial("GB2") + "' AND D_E_L_E_T_ <> '*'"
cSql += "    AND GB2_TPNASC = '0' "
TcSqlExec(cSql)

cSql := " UPDATE " + RetSqlName("GB2")
cSql += "    SET GB2_NOME = 'RN ' "+cConcat+" '(' "+cConcat+" GB2_TPNASC "+cConcat+" ') ' "+cConcat+" '" + SUBSTR(M->GBH_NOME,1,TAMSX3("GB2_NOME")[1] - 7) + "' "
cSql += "  WHERE GB2_REGATE IN (SELECT GCY_REGATE "
cSql += "                         FROM " + RetSqlName("GCY")
cSql += "                        WHERE GCY_REGGER = '" + M->GBH_CODPAC + "')"
cSql += "    AND GB2_FILIAL = '" + xFilial("GB2") + "' AND D_E_L_E_T_ <> '*'"
cSql += "    AND GB2_TPNASC IN ('1','2','3','4','5') "
TcSqlExec(cSql)

cSql := " UPDATE "+ RetSqlName("GAV") + Iif(Alltrim(cConcat) == "+",""," GAV")
cSql += "    SET GAV_NOME = (SELECT GB2_NOME "
cSql += "                      FROM "+ RetSqlName("GB2")+ " GB2 "
cSql += "                     WHERE GB2.GB2_FILIAL =  '" + xFilial("GB2") + "'"
cSql += "                       AND GB2.D_E_L_E_T_ <> '*' "
cSql += "                       AND GB2.GB2_REGATE = GAV.GAV_REGATE "
cSql += "                       AND GB2.GB2_TPNASC = GAV.GAV_RESERV ) "
cSql += Iif(Alltrim(cConcat) == "+","  FROM "+ RetSqlName("GAV")+" GAV ","")
cSql += " WHERE GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*'  "
cSql += "  AND  GAV.GAV_RESERV IN ('0','1','2','3','4','5') "
cSql += "  AND  GAV_REGATE <> '' "
cSql += "  AND  GAV_REGATE IN (SELECT GCY_REGATE "
cSql += "                         FROM " + RetSqlName("GCY")
cSql += "                        WHERE GCY_REGGER = '" + M->GBH_CODPAC + "')"
TcSqlExec(cSql)

cSql := " UPDATE "+ RetSqlName("GAI") + Iif(Alltrim(cConcat) == "+",""," GAI")
cSql += "    SET GAI_NOMPAC = (SELECT " + Iif(Alltrim(cConcat) == "+","SUBSTRING","SUBSTR") + "(GB2_NOME, 1 , "+Alltrim(Str(TamSx3("GAI_NOMPAC")[1]))+") "
cSql += "                        FROM "+ RetSqlName("GB2")+ " GB2 "
cSql += "                       WHERE GB2.GB2_FILIAL =  '" + xFilial("GB2") + "'"
cSql += "                         AND GB2.D_E_L_E_T_ <> '*' "
cSql += "                         AND GB2.GB2_REGATE = GAI.GAI_REGATE "
cSql += "                         AND GB2.GB2_TPNASC = GAI.GAI_RESERV ) "
cSql += Iif(Alltrim(cConcat) == "+","  FROM "+ RetSqlName("GAI")+" GAI ","")
cSql += "  WHERE GAI.GAI_FILIAL = '" + xFilial("GAI") + "'  AND GAI.D_E_L_E_T_ <> '*' "
cSql += "    AND GAI.GAI_RESERV in ('0','1','2','3','4','5') "
cSql += "    AND GAI.GAI_REGATE <> '' "
cSql += "    AND GAI.GAI_REGATE IN (SELECT GCY_REGATE "
cSql += "                             FROM " + RetSqlName("GCY")
cSql += "                            WHERE GCY_REGGER = '" + M->GBH_CODPAC + "')"
TcSqlExec(cSql)

cSql := " UPDATE "+ RetSqlName("GFU") + Iif(Alltrim(cConcat) == "+",""," GFU")
cSql += "    SET GFU_NOMPAC = (SELECT " + Iif(Alltrim(cConcat) == "+","SUBSTRING","SUBSTR") + "(GB2_NOME, 1 , "+Alltrim(Str(TamSx3("GFU_NOMPAC")[1]))+") "
cSql += "                        FROM "+ RetSqlName("GB2")+ " GB2 "
cSql += "                       WHERE GB2.GB2_FILIAL =  '" + xFilial("GB2") + "'"
cSql += "                         AND GB2.D_E_L_E_T_ <> '*' "
cSql += "                         AND GB2.GB2_REGATE = GFU.GFU_REGATE "
cSql += "                         AND GB2.GB2_TPNASC = GFU.GFU_RESERV ) "
cSql += Iif(Alltrim(cConcat) == "+","  FROM "+ RetSqlName("GFU")+" GFU ","")
cSql += "  WHERE GFU.GFU_FILIAL = '" + xFilial("GFU") + "'  AND GFU.D_E_L_E_T_ <> '*' "
cSql += "    AND GFU.GFU_RESERV in ('0','1','2','3','4','5') "
cSql += "    AND GFU.GFU_REGATE <> '' "
cSql += "    AND GFU.GFU_REGATE IN (SELECT GCY_REGATE "
cSql += "                             FROM " + RetSqlName("GCY")
cSql += "                            WHERE GCY_REGGER = '" + M->GBH_CODPAC + "')"
TcSqlExec(cSql)


RestArea(aArea)

Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ValId  บ       ณAdriano Orlovski    บ Data ณ  07/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para validar idade de reponsabilidade do paciente   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOPS - 122713                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION FS_ValId()
Local aArea 			:= GetArea()
Local nCont := 0
Local lRet  := .T.

If !HS_VMaior(M->GBH_IDADE)

	For nCont := 1 to Len(oGFD:aCols)
		If HS_VMaior(oGFD:aCols[nCont, nGFD_Idade], ,.F.)
			RestArea(aArea)
			Return(.T.)
		Endif
	Next nCont

	lRet := .F.
	HS_MsgInf(STR0055,STR0009,STR0056) //"O Paciente deve possuir um responsแvel maior de idade."###"Aten็ใo"###"Valida็ใo da Idade do Paciente"
EndIf

RestArea(aArea)
Return(lRet)

Function HS_VMaior(cIdade, lShowMsg, lRetEmpty)
Local lRet   := .T.
Local nIdade := IIF(!Empty(cIdade),VAL(SUBSTR(cIdade,1,AT("a",cIdade)-1)),"")
Local nValidad := GetMV("MV_VALIDAD",,0)

Default lShowMsg  := .F.
Default lRetEmpty := .T.

If !Empty(nIdade)
	If (nIdade < nValidad)
		If lShowMsg
			HS_MsgInf(STR0058+Str(nValidad)+STR0059,STR0060,STR0061 )//"Idade nใo pode ser menor do que "+"xx"+" Anos."###"Aten็ใo idade inferior ao parโmetro MV_VALIDAD"###"Valida็ใo da Idade"
		EndIf
		Return(.F.)
	EndIf
Else
	lRet := lRetEmpty
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_AtrLoc บ       ณHEIMDALL CASTRO     บ Data ณ  19/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใoi usada para preencher o codigo e nome do local,     บฑฑ
ฑฑบ          ณ onde o paciente estแ sendo atendido.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_AtrLoc()
Local cNomLoc := Space(HS_CfgSx3("GBH_NOMLOC")[SX3->(FieldPos("X3_TAMANHO"))])
Local cCodLoc := IIF(Type('cM24Par01')<>'U' .And. Inclui, cM24Par01, '')

If Empty(cCodLoc) .And. !Inclui
	cCodLoc := GBH->GBH_CODLOC
EndIf

cNomLoc := HS_INIPADR("GCS", 1, cCodLoc, "GCS_NOMLOC",, .F.)


Return(cNomLoc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PreCNS บ       ณMario Arizono       บ Data ณ  09/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para preenchimento do campo numero CNS    บฑฑ
ฑฑบ          ณ de acordo com o plano SUS do Paciente.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PreCNS()
Local aAreaOld := GetArea()
Local lRet     := .T.
Local  aVSus   := {GETMV("MV_PCONSUS"), GETMV("MV_PSUSBPA"), GETMV("MV_PSUSPAC"), GETMV("MV_PSUSAIH")}

If !( len(oGD4:aCols) == 1 .And. Empty(oGD4:aCols[1,nGD4_CODPLA]) )
	If !Empty(aVSus[1])
		If (nPos := aScan(oGD4:aCols, {|aVetDes| aVetDes[nGD4_CODPLA] == aVSus[2] .And. !aVetDes[nUGD4 + 1]})) == 0 .Or. aVSus[1] <> HS_IniPadr("GCM", 2, oGD4:aCols[nPos,nGD4_CODPLA], "GCM_CODCON",, .F.)
			If (nPos := aScan(oGD4:aCols, {|aVetDes| aVetDes[nGD4_CODPLA] $ aVSus[3] .And. !aVetDes[nUGD4 + 1] })) == 0 .Or. aVSus[1] <> HS_IniPadr("GCM", 2, oGD4:aCols[nPos,nGD4_CODPLA], "GCM_CODCON",, .F.)
				If (nPos := aScan(oGD4:aCols, {|aVetDes| aVetDes[nGD4_CODPLA] == aVSus[4] .And. !aVetDes[nUGD4 + 1]})) > 0
					If aVSus[1] <> HS_IniPadr("GCM", 2, oGD4:aCols[nPos,nGD4_CODPLA], "GCM_CODCON",, .F.)
						nPos := 0
					Endif
				Endif
			Endif
		Endif

		If nPos > 0
			M->GBH_NUMCNS := IIF(!Empty(oGD4:aCols[nPos,nGD4_MATRIC]), SUBSTR(oGD4:aCols[nPos,nGD4_MATRIC], 1, LEN(GBH->GBH_NUMCNS)), M->GBH_NUMCNS)
		Else
			If (aScan(oGD4:aCols, {|aVetDes| SUBSTR(aVetDes[nGD4_MATRIC],1,LEN(GBH->GBH_NUMCNS)) == M->GBH_NUMCNS .And. aVetDes[nUGD4 + 1]}) > 0)
				M->GBH_NUMCNS := SPACE(LEN(GBH->GBH_NUMCNS))
			Endif
		EndIf
	Endif
Endif

RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CNSDUP บ       ณRogerio Tabosa      บ Data ณ  15/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para validaco do campo numero CNS se o    บฑฑ
ฑฑบ          ณ mesmo informado jแ existe para outro paciente.(Duplicidade)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CNSDUP()
Local aAreaOld 	:= GetArea()
Local lRet     	:= .T.
Local aVSus   := {GETMV("MV_PCONSUS"), GETMV("MV_PSUSBPA"), GETMV("MV_PSUSPAC"), GETMV("MV_PSUSAIH")}
Local cCNSIn	:= ""
Local nLin 		:= 0
Local lVldCnsPP	:= GetNewPar("MV_VLCNSPP",.T.) //Informa se deseja bloquear a grava็ใo na valida็ใo de duplicidade do CNS para o Paciente e Profissional (.T. = Sim - Padrao /.F. = Nao)

If !Empty(M->GBH_NUMCNS)
	cCNSIn += "'" + Alltrim(M->GBH_NUMCNS) + "'"
EndIf

For nLin := 1 to Len(oGD4:aCols)
	If !Empty(oGD4:aCols[nLin,nGD4_CODPLA]) .AND. (oGD4:aCols[nLin,nGD4_CODPLA] $ aVSus[4] .OR. oGD4:aCols[nLin,nGD4_CODPLA] $ aVSus[3] .OR. oGD4:aCols[nLin,nGD4_CODPLA] $ aVSus[2])
		If !Empty(oGD4:aCols[nLin,nGD4_MATRIC])
			If !Empty(cCNSIn)
				cCNSIn += ",'" + Alltrim(oGD4:aCols[nLin,nGD4_MATRIC]) + "'"
			Else
				cCNSIn += "'" + Alltrim(oGD4:aCols[nLin,nGD4_MATRIC]) + "'"
			EndIf
		EndIf
	EndIf
Next nLin

If !Empty(cCNSIn)
	If HS_CountTB("GBH", "GBH_NUMCNS IN (" +  cCNSIn + ") AND GBH_CODPAC <> '" + M->GBH_CODPAC +"'") > 0
		HS_MSGINF(STR0065,STR0009, STR0001) // "O CNS informado jแ foi atribuido para outro paciente!"
		lRet := IIf (lVldCnsPP,.F.,.T.)
	ElseIf 	HS_CountTB("GD4", "GD4_MATRIC IN (" +  cCNSIn + ") AND GD4_REGGER <> '" + M->GBH_CODPAC +"'") > 0      // "O CNS informado jแ foi atribuido para outro paciente!"
		HS_MSGINF(STR0065,STR0009, STR0001)
		lRet := IIf (lVldCnsPP,.F.,.T.)
	ElseIf 	HS_CountTB("GBJ", "GBJ_CODCNS IN (" +  cCNSIn + ") ") > 0
		HS_MSGINF(STR0066,STR0009, STR0001) //"O CNS informado jแ foi atribuido para um profissional!"
		lRet := IIf (lVldCnsPP,.F.,.T.)
	EndIf
EndIf

RestArea(aAreaOld)
Return(lRet)

Static Function FS_PRESUS()
Local aPar 		:= {{"MV_PCONSUS",""},{"MV_PSUSBPA",""},{"MV_PSUSPAC",""},{"MV_PSUSAIH",""}}

If !INCLUI
	Return()
ElseIf !HS_VMVSUS(@aPar,.T.)
	Return()
ElseIf M->GBH_PACSUS <> "1"
	Return()
EndIf

If Len(oGD4:aCols) == 1 .AND. Empty(oGD4:aCols[1,nGD4_CODPLA])
	oGD4:aCols[1,nGD4_CODPLA] 	:= aPar[2, 2]
	oGD4:aCols[1,nGD4_DESPLA]	:= HS_IniPadR("GCM", 2, aPar[2, 2], "GCM_DESPLA",, .F.)

	oGD4:AddLine()
	oGD4:lNewLine := .F.
	oGD4:aCols[len(oGD4:aCols), nGd4_IdPadr] := IIF(len(oGD4:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado
	oGD4:aCols[len(oGD4:aCols), nGd4_IdDoac] := IIF(len(oGD4:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado

	oGD4:aCols[2,nGD4_CODPLA] 	:= aPar[3, 2]
	oGD4:aCols[2,nGD4_DESPLA]	:= HS_IniPadR("GCM", 2, aPar[3, 2], "GCM_DESPLA",, .F.)

	oGD4:AddLine()
	oGD4:lNewLine := .F.
	oGD4:aCols[len(oGD4:aCols), nGd4_IdPadr] := IIF(len(oGD4:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado
	oGD4:aCols[len(oGD4:aCols), nGd4_IdDoac] := IIF(len(oGD4:aCols) == 1, "LBTIK", "LBNO") //Se primeira ocorrencia, gera marcado


	oGD4:aCols[3,nGD4_CODPLA] 	:= aPar[4, 2]
	oGD4:aCols[3,nGD4_DESPLA]	:= HS_IniPadR("GCM", 2,aPar[4, 2], "GCM_DESPLA",, .F.)

	oGD4:oBrowse:Refresh()
EndIf

Return()

Static Function FS_REPDSUS()
Local nI 		:= 0
Local cMat 		:= oGD4:aCols[oGD4:oBrowse:nAt, nGD4_MATRIC]
Local dDatVal 	:= oGD4:aCols[oGD4:oBrowse:nAt, nGD4_DTVALI]
Local cNomTit 	:= oGD4:aCols[oGD4:oBrowse:nAt, nGD4_NOMTIT]

If !INCLUI
	Return(.T.)
ElseIf Len(oGD4:aCols) <= 1
	Return(.T.)
ElseIf M->GBH_PACSUS <> "1"
	Return(.T.)
EndIf

For nI := 1 to Len(oGD4:aCols)
	If !Empty(cMat)
		oGD4:aCols[nI, nGD4_MATRIC]	:= cMat
	EndIf
	If !Empty(dDatVal)
		oGD4:aCols[nI, nGD4_DTVALI]	:= dDatVal
	EndIf
	If !Empty(cNomTit)
		oGD4:aCols[nI, nGD4_NOMTIT]	:= cNomTit
	EndIf
Next nI

oGD4:oBrowse:Refresh()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A58WhenบAutor  ณDarcio Ribeiro Sporlบ Data ณ  21/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para verificar se o paciente eh ou nao titularบฑฑ
ฑฑบ          ณdo plano, caso seja, nao ha necessidade de preencher os     บฑฑ
ฑฑบ          ณcampos relacionados ao titular.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A58When()
LOCAL lRet := .F.
LOCAL nPosT	:= aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_SNTITU"})

If nPosT > 0
	If oGD4:aCols[oGD4:nAt, nPosT] == 'N'
		lRet := .T.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A58Clr บAutor  ณDarcio Ribeiro Sporlบ Data ณ  21/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para limpar os campos referente ao titular,   บฑฑ
ฑฑบ          ณcaso volte a opcao para titular = sim.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A58Clr()
LOCAL nPosT	:= aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_SNTITU"})
LOCAL nPosR := aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_REGTIT"})
LOCAL nPosN	:= aScan(oGD4:aHeader, {|aVet| aVet[2] == "GD4_NOMTI1"})

If M->GD4_SNTITU == 'S'
	oGD4:aCols[oGD4:nAt, nPosR] := Space(TamSX3("GD4_REGTIT")[1])
	oGD4:aCols[oGD4:nAt, nPosN] := Space(TamSX3("GD4_NOMTI1")[1])
	oGD4:Refresh()
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGD  บAutor  ณSaude               บ Data ณ  19/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada para gravar os dados referentes ao Pacienteบฑฑ
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
	lAchou := DbSeek(xFilial(cAlias) + M->GBH_CODPAC + aCols[nForI ,nCodItem])
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
			&(cPGrv + "_CODPAC") := M->GBH_CODPAC
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VREDPROบAutor  ณSaude               บ Data ณ  08/12/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o paciente e seu convenio ้ de Rede Propria     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VREDPRO(cRegGer)
Local aArea		:= GetArea()
Local lRet		:= .F.

DbSelectArea("GD4")
DbSetOrder(2)
If DbSeek(xFilial("GD4") + cRegGer + "1")
	DbSelectArea("GA9")
	DbSetOrder(1)
	If DbSeek(xFilial("GA9") + GD4->GD4_CODCON)
		lRet := (GA9->GA9_REDPRO == "1")
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VERBTSบAutor  ณSaude               บ Data ณ  27/01/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o paciente ja existe no Modulo Plano de Saude   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VERBTS(nIndice,cCampo)
local lret:=.T.
local lExistBTS:=.F.
Local aArea		:= GetArea()
Local aRet		:= {0,0} //Recno BA1 , Recno BA3
Local cQryBA1	:= ""
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", "99")	// Pega a empresa de trabalho do PLS
Local cFilTrab	:= PADR(GetNewPar("MV_FILIPLS", " "),FWSizeFilial())	// Pega a filial de trabalho do PLS
Local lEspelhar := GetNewPar("MV_INTBTGB",.F.) // Parametro Integracao das Tabelas de vidas PLS X GH

If !Inclui .or. !lEspelhar
	Return(lret)
Endif
Hs_TabPLS("A",cFilTrab)	// Abre as tabelas da empresa referente ao PLS

DbSelectArea("BTS")
BTS->( dbSetorder(nIndice) )
If (BTS->(MsSeek(xFilial("BTS")+cCampo) ) .or. BTS->(MsSeek(xFilial("BTS")+alltrim(cCampo)) ) )

	If nIndice==2
		While !BTS->( Eof() ) .and. Alltrim(BTS->BTS_NOMUSR) == Alltrim(cCampo)
			lExistBTS := .T.
			Exit

			BTS->( dbSkip() )
		Enddo
	Endif

	If lExistBTS:=MsgYesNo(STR0073 + STR0017)//"Jแ existe Cadastro com o mesmo RG e Data de Nascimento com o prontuแrio: "###"  Deseja Continuar?"
		lRet := .T.
		M->GBH_MATVID:=BTS->BTS_MATVID
		M->GBH_NOME  :=BTS->BTS_NOMUSR
		M->GBH_CPF   :=BTS->BTS_CPFUSR
		M->GBH_RG    :=BTS->BTS_DRGUSR
		M->GBH_DTNASC:=BTS->BTS_DATNAS
		M->GBH_CEP   :=BTS->BTS_CEPUSR
		M->GBH_END   :=BTS->BTS_ENDERE
		M->GBH_NUM   :=BTS->BTS_NR_END
		M->GBH_COMPLE:=BTS->BTS_COMEND
		M->GBH_MUN   :=BTS->BTS_MUNICI
		M->GBH_EST   :=BTS->BTS_ESTADO
		M->GBH_TEL   :=BTS->BTS_TELEFO
		M->GBH_NOMPAI:=BTS->BTS_PAI
		M->GBH_NOMMAE:=BTS->BTS_MAE
		M->GBH_IDADE :=HS_A58AGE()
		M->GBH_BAIRRO:=BTS->BTS_BAIRRO
	Endif

Endif
Hs_TabPLS("F",cFilTrab)	// Fecha as tabelas referente ao PLS

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A58DOK  บAutor  ณMicrosiga           บ Data ณ  10/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function HS_A58DOK(cMativi)
Local lRet:=.T.

		BA1->(DbSetOrder(7))
		If BA1->(DbSeek(xFilial("BA1")+cMativi))
			Help("",1,"PLSA955EXC")
		lRet:=.F.
		Endif


Return(lRet)
