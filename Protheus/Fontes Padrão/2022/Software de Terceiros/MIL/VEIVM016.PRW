// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "veivm016.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM016 ³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transferencia de  Veiculos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM016()

DEFINE FONT oFnt3 NAME "Arial" SIZE 08,13 BOLD
DEFINE FONT oFnt4 NAME "Arial" BOLD
DEFINE FONT oFnt7 NAME "Times New Roman" SIZE 07,13 BOLD

Private bFiltraBrw := {|| Nil}
Private cNovUsa
Private aEstoque, aOutMoed
Private cNumPed, lMudSimVda, nOpcMnu
Private cDesMar, cDesMod, cDesCor , cTipFat, cObserv, dDatMov
Private dDatEmi, cEstCli, cNumNfi, cSerNfi, cDesFpg, cNomVen, cNomCli ,	cNfiOri, cSerOri, cCodMap, cTipPag, cDesPag,cNomBco
Private oLbParc, oNomCli
Private lTroco := .f.
// Variaveis para a Condicao de Pagto
Private cTipPag1
Private oScroll, odlgfold, oObjTel, oCodCDCI
Private nC := nV := nS := 1
Private cCodCDCI  := Space(4)
Private aColsV    := {}
Private aHeaderV  := {}
Private cTipOpe   := 3  //Veiculos
Private nTotalEnt := 0
Private nAliIss    := GETMV("MV_TXISS")  / 100
Private nAliPis    := GETMV("MV_TXPIS")  / 100
Private nAliCof    := GETMV("MV_TXCOFIN")/ 100
Private cGruVei    := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private nc         := 1
Private nUsadoC    := 1
Private aIteParc   := {{cTod(""),0}}
Private cCondic1   := ctod(" ")
Private cCondic2   := space(02)
Private cCondic3   := space(02)
Private cCondic4   := space(02)
Private cCondic5   := "1"
Private lAbortPrint:= .f.
Private cParPrg    := "3"
Private cTipSai    := "2"  //Transferencia
Private cTipoMov := "T"
//Private aMemos     := {{"VVA_OBSMEM","VVA_OBSERV"}}
Private aMemos     := {{"VV0_OBSMEM","VV0_OBSERV"}}
Private acolsC     := aHeaderC := aGravaEnt := {}
Private cSimVda    := "V"
Private lJaGrv     := .f.
Private cSerie     := ""
Private cSitVei    := "0"
Private cAlias     := "VV0"
Private cPrefNF    := ""
Private cPrefix    := GetNewPar("MV_PREFVEI","VEI")
Private cEstoque   := "S"
Private nValEqp    := 0
Private nTotEnt    := 0
Private oFnt6      := TFont():New( "Times New Roman", 7, 17 )
Private aTipFat    := {OemToAnsi(STR0001),OemToAnsi(STR0002)} //0=Novo # 1=Usado
Private cCodBco    := ""
Private nTotEntr   := 0
Private cNumLib    := " "
Private nValCor    := 0
Private aCampoVV1  := {}
Private lFilTrans  := .t.
Private lMsHelpAuto:= .f.
Private lMsErroAuto:= .f.
Private aRotina    := MenuDef()
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
Private cNota := cNumero := ""

Private lMudouNum := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro  := OemToAnsi(STR0003) //Transferencia de Veiculos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
cIndex    := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao :='VV0->VV0_OPEMOV $ "2" .and. VV0->VV0_SITNFI == "1"' // Transferencia
IndRegua("VV0",cIndex,cKey,,cCondicao,OemToAnsi(STR0004))  // "Selecionando Registros..."
DbSelectArea(1)

mBrowse( 6, 1,22,75,"VV0")

DbSelectArea("VV0")
Set Filter to
RetIndex("VV0")
DbsetOrder(1)

#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TRANSFE³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Transferencia de Veiculos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TRANSFE(cAlias, nReg, nOpc)

Local oDlg
Local oFont
Local cont
Local oDlgFolder, ni
Local nRecno   := VV0->(Recno())
Local nOrdem   := IndexOrd()
Local cPrimeiro:= ""
Local nControl := 0
Local nOk      := 0
Local aPages   := {}
Local aVar     := {}
Local bCampo	:= { |nCPO| Field(nCPO) }
Local aTitles  := {OemToAnsi(STR0005)} // Dados da Transferencia
Local nCntFor,_ni  := 0
Private cChaInter	:= " "
Private aAcols    := {}
Private lBaseIcm  := .f.
Private lValIcm   := .f.
Private nAcresFin := 0 // Cria Variavel para compatib. com o VEIVM011

cCadastro  := OemToAnsi(STR0006) //Transferencia de Veiculos

lTelVdaSim := lJaGrv := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de atendimento ao cliente                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV9")
While x3_arquivo == "VV9" .and. !eof()
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de remessa                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
aPriEnc := {}
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV0_CODCLI/VV0_LOJA/VV0_NOMCLI/VV0_CODVEN/VV0_NOMVEN/VV0_CHASSI/VV0_CHAINT/VV0_DESMAR/VV0_DESGRU/VV0_DESMOD/VV0_FABMOD/VV0_PLAVEI/VV0_VALMOV/VV0_FORPAG/VV0_DESFPG/VV0_CODTES/VV0_VBAICM/VV0_ALIICM/VV0_TOTICM/VV0_OBSERV/VV0_OBSMEM/VV0_BASSOL/VV0_VALSOL/VV0_VALTOT/VV0_CODTRA/VV0_TPFRET"
		AADD(aPriEnc,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de atendimento ao cliente                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
While x3_arquivo == "VVA" .and. !eof()
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

if !Inclui
	dbSelectArea("VV0")
	dbGoto(nRecno)
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	dbSelectArea("VVA")
	dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	
	M->VV0_CHAINT := VVA->VVA_CHAINT
	M->VV0_CHASSI := VVA->VVA_CHASSI
	M->VV0_CODTES := VVA->VVA_CODTES
	
	//	M->VV0_VALTOT := M->VV0_VALMOV
	
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	M->VV0_CODMAR := VV1->VV1_CODMAR
	M->VV0_DESMAR := VE1->VE1_DESMAR
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	M->VV0_MODVEI := VV1->VV1_MODVEI
	M->VV0_DESMOD := VV2->VV2_DESMOD
	M->VV0_CHASSI := VV1->VV1_CHASSI
	M->VV0_CODFRO := VV1->VV1_CODFRO
	M->VV0_PLAVEI := VV1->VV1_PLAVEI
	M->VV0_FABMOD := VV1->VV1_FABMOD
	dbSelectArea("VVR")
	dbSetOrder(2)
	dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD)
	M->VV0_GRUMOD := VV2->VV2_GRUMOD
	M->VV0_DESGRU := VVR->VVR_DESCRI
	
	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	if alltrim(SX3->X3_CAMPO) == "VV0_DESCOR"
		cRet := VVC->VVC_DESCRI
	Endif
	M->VV0_DESCOR := VVC->VVC_DESCRI
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	M->VV0_NOMCLI := SA1->A1_NOME
	
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+VV0->VV0_FORPAG)
	M->VV0_DESFPG := SE4->E4_DESCRI
	
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+VV0->VV0_CODVEN)
	M->VV0_NOMVEN := SA3->A3_NOME
	
	cCadastro := cCadastro + " - [" + VV0->VV0_NUMTRA	+ "]"
Endif

//Zera as variaveis fiscais
MaFisEnd()

if nOpc <> 3  //Consulta ou Alteracao
	//Variavei usadas no Veivm010 da condicao de pagamento
	aHeaderC := {}
	aColsC   := {}
	nUsadoC  := 0
	/*
	If FS_CARDAD(nOpc) == .f.
	Return
	Endif
	*/
	DbSelectArea("VV0")
Else    //Inclusao
	lValGeral := .T.
	M->VVA_ALIICM := val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2))
	M->VVA_VALVEI := M->VVA_VALMOV := M->VVA_VBAICM := M->VVA_ICMVEN := M->VVA_VALDES := M->VVA_VALVDA := nValEqp := 0
	cTipFat := Space(01)
	M->VV0_FORPAG := M->VV1_CODMAR := cSerNfi := Space(3)
	M->VV0_LOJA:= M->VV0_LOJAAV:= Space(TAMSX3("VV0_LOJA")[1])

//	M->VV0_CODCLI := M->VVA_CHAINT := M->VV1_CHAINT := Space(06)
//FNC 23656/2010 - Boby 29/11 - Alterar atribuição do campo M->VV0_CODCLI, de space(06) para TamSx3()
	M->VVA_CHAINT := M->VV1_CHAINT := Space(TAMSX3("VV1_CHAINT")[1])
	M->VV0_CODCLI := Space(TAMSX3("VV0_CODCLI")[1])

	M->VV1_MODVEI := cNomVen := cDesMod :=  cDesCor := cDesMar := cDesFpg := cNomBco := cNomCli := Space(15)
	M->VVA_CHASSI := Space(TAMSX3("VVA_CHASSI")[1])
	dDatMov := dDatEmi := dDataBase
Endif

cObserv := E_MSMM(VV0->VV0_OBSMEM,68)
M->VV0_OBSERV := cObserv

Private lExclui := nOpc == 4
Private oFolderV
Private oEnc01
Private nOpcao   := nOpc
Private lOk      :=.F.
Private aSvAtela := {{}}
Private aSvAGets := {{}}
Private aTela    :={}
Private aGets    :={}
cAliasEnchoice   := "VV0"
cAliasGetD       := "VVA"
cLinOk           := "CheckCols(n,aAcols)"
cFieldOk         := "AllwaysTrue()"
cTudOk           := "FS_TudoOk()"
nOpca            := 0

Private aSvtela
Private aSvGets

aSvtela  := {{},{}}
aSvGets  := {{},{}}

SETAPILHA()
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM  4,0 To 30,80 OF oMainWnd

aTela := {}
aGets := {}
dbSelectArea("VV0")
Zero()
oGetMGet1:= MsMGet():New("VV0",0,nOpc,,,,aPriEnc,{010,000,203,315},,2,,,,oDlgFolder,,.T.,.F.,"aSvTela[1]",.t.)
oGetMGet1:oBox:bGotFocus   := {|| AL_Entra(1,"VV0") }
oGetMGet1:oBox:bLostFocus  := {|| AL_Sai(1)}
aSvTela[1] := aClone(aTela)
aSvGets[1] := aClone(aGets)

ACTIVATE MSDIALOG oDlgFolder CENTER ON INIT EnchoiceBar(oDlgFolder,{|| Processa({|| Fs_TTudoOk(nOpc) }),if(nOpca == 1,oDlgFolder:End(),.f.)},{||nOpca := 2,oDlgFolder:End()} )

DbSelectArea("VV0")
DbSelectArea(1)

Return


/////////////////////////
Function Fs_TTudoOk(nOpc)

Local lRet := .t.
Local i:=0

Private cGruVei   := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private lMsErroAuto := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rafael - 15/12/2009 - Solicitado Pelo Manoel                 ³
//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aPriEnc)
	If X3Obrigat(aPriEnc[i]) .and. Empty(&("M->"+aPriEnc[i]))
		//		Help(" ",1,"OBRIGAT2",,RetTitle(aPriEnc[i]),4,1 )
		MsgInfo("Existe campo obrigatorio nao informado:  - "+RetTitle(aPriEnc[i]))
		Return
	EndIf
Next


nOpca := 2
lTelVdaSim := .f.
ProcRegua(6)

if nOpc == 2
	nOpca := 1
	Return .t.
Endif

VV1->(dbSetOrder(2))
if !VV1->(dbSeek(xFilial("VV1")+M->VV0_CHASSI))
	Help(" ",1,"VENCADM010")
	Return .f.
Endif
VV1->(dbSetOrder(1))

M->VV0_CHAINT := VV1->VV1_CHAINT
M->VVA_CHAINT := VV1->VV1_CHAINT
M->VVA_CODTES := M->VV0_CODTES

if !lExclui .and. nOpc == 3
	if VV1->VV1_SITVEI == "0"
		if VV1->VV1_RESERV $ "1/3"
			if !Empty(VV1->VV1_FILIAL)
				if nOpc <> 2 .and. Alltrim(VVA->VVA_USUARI) <> Alltrim(Upper(Subs(cUsuario,7,15)))
					dbSelectArea("VVA")
					nRecVVA := Recno()
					dbSeek(xFilial("VVA")+VV1->VV1_NUMTRA)
					cDatS   := dToS(cToD(subs(VV1->VV1_DTHRES,1,8)))
					cDatRes := Subs(cDatS,7,2) + "/" + Subs(cDatS,5,2) + "/" + Subs(cDatS,1,4)
					cMensStr:= STR0007+" " + Alltrim(VVA->VVA_USUARI) + " "+STR0008+" " + cDatRes + " "+STR0009+" " + subs(VV1->VV1_DTHRES,10) + "h"  //Este Veiculo foi reservado pelo(a) funcionario(a) # no dia # as
					MsgStop(OemToAnsi(cMensStr),OemtoAnsi(STR0010)) //Atencao
					dbGoto(nRecVVA)
					Return .f.
				Endif
			Endif
		Elseif VV1->VV1_SITVEI == "1"
			MsgInfo(STR0011,STR0010)//Veiculo esta Vendido # Atencao
			Return .f.
		Elseif VV1->VV1_SITVEI == "5"
			MsgInfo(STR0012,STR0010)//Veiculo ja foi Trasferido # Atencao
			Return .f.
		Elseif VV1->VV1_SITVEI == "3"
			MsgInfo(STR0013,STR0010)//Veiculo nao esta em Remessa # Atencao
			Return .f.
		Endif
	Endif
	
	SF4->(dbSetOrder(1))
	If !SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
		Help(" ",1,"TESNCDM010")
		Return .f.
	Else
		if !Val(M->VV0_CODTES) >= 500
			Help(" ",1,"TESINVM010")
			Return .f.
		Endif
	Endif
	
	if Empty(VV1->VV1_LOCPAD)
		cLocVei := GETMV("MV_LOCVEIN") //Novo
		if VV1->VV1_ESTVEI == '1'
			cLocVei := GETMV("MV_LOCVEIU") //Usado
		Endif
		if VV1->VV1_SITVEI == "4" //Consignado
			cLocVei := GETMV("MV_LOCVEIC")
		Endif
	Else
		cLocVei := VV1->VV1_LOCPAD
	Endif
	
	M->VV0_CHASSI := VV1->VV1_CHASSI
	M->VV0_CHAINT := VV1->VV1_CHAINT
	M->VVA_CHASSI := VV1->VV1_CHASSI
	M->VVA_CHAINT := VV1->VV1_CHAINT
	
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	dbSelectArea("SB1")
	dbSetOrder(7)
	if dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
		dbSelectArea("SB2")
		dbSetOrder(1)
		if !dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei) .or. SB2->B2_QATU <= 0
			MsgInfo(STR0014,STR0010)//Veiculo nao esta no Estoque # Atencao
			Return .f.
		Endif
	Else
		MsgInfo(STR0014,STR0010)//Veiculo nao esta no Estoque # Atencao
		Return .f.
	EndIF
	
	lJaGrv := .f.
	M->VV0_OPEMOV := "2"
	nToEnt := M->VV0_VALMOV
	M->VVA_VALMOV := nToEnt
	
	If !FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
		
		cNota := cNumero
		Begin Transaction
		IncProc(STR0015) // Gravando Transferencia
		FS_GRAVA010("S",nOpc)
		IncProc(STR0015) // Gravando Transferencia
		FS_GRAVA010("G",nOpc)
		
		If ExistBlock("VM016DNF")
			ExecBlock("VM016DNF",.f.,.f.)
		EndIf
		reclock("VVA",.f.)
		VVA->VVA_ALIICM := SD2->D2_PICM
		msunlock()
		reclock("VV0",.f.)
		VV0->VV0_VBAICM := SD2->D2_BASEICM
		VV0->VV0_ALIICM := M->VV0_ALIICM
		VV0->VV0_TOTICM := SF2->F2_VALICM
		VV0->VV0_VALTOT := M->VV0_VALTOT
        MSMM(,TamSx3("VV0_OBSERV")[1],,&(aMemos[1][2]),1,,,"VV0","VV0_OBSMEM")
		msunlock()
		End Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX6")
		MsRUnLock()

		if lMsErroAuto
			lRet := .f.
			MostraErro()
		Else
			nOpca := 1
			if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
				If ExistBlock("NFSAIVEI")
					ExecBlock("NFSAIVEI",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI})
				Endif
			EndIF
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)

			FM_LOCVZL(2)
			FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
		Endif
	Endif
Else
	if lExclui
		If MsgYesNo(OemToAnsi(STR0016),OemToAnsi(STR0010))//Cancela a Transferencia?  # Atencao
			Processa( {|| FS_GRACAN() }," "," ",.t. )
			if lMsErroAuto
				lRet := .f.
				MostraErro()
			Else
				nOpca := 1
				dbSelectArea("SB1")
				dbSetOrder(7)
				dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
				//
				FM_LOCVZL(1)
				FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
			Endif
		Endif
	Endif
Endif
//
Return(lRet)

Static Function MenuDef()
Local aRotina := { {OemtoAnsi(STR0017)   ,"axPesqui"  , 0 ,1},;    //Pesquisar
{OemtoAnsi(STR0018)  ,"FS_TRANSFE", 0, 2},;    //Consultar
{OemtoAnsi(STR0019)  ,"FS_TRANSFE", 0, 3},;    //Incluir
{OemtoAnsi(STR0020)  ,"FS_TRANSFE", 0, 5},; 	//Cancelar
{OemtoAnsi(STR0021)  ,"VM016_LVEI" , 0 , 2}}   //Pesquisa Chassi

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM016_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM016_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private overd := LoadBitmap( GetResources() , "BR_VERDE" )
Private overm := LoadBitmap( GetResources() , "BR_VERMELHO" )
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
EndDo
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi("Pesquisa Chassi") FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
@ 003,004 SAY "Veiculo"+":" SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE//Veiculo
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi("SAIR") OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER 	OemToAnsi("Filial"),;	//Filial
OemToAnsi("Dt.Movimento"),; //Dt.Movimento
OemToAnsi("NF/Serie"),; //NF/Serie
OemToAnsi("Valor"),; //Valor
OemToAnsi("Cliente"); //Cliente
COLSIZES 35,37,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	   	aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VV0")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	dbSetOrder(1)//NUMTRA
	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local lOk := .t.
Local cQuery := ""
Local cQAlVV0 := "SQLVV0"
Local cFilLibs := ""
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_OPEMOV, VV0.VV0_SITNFI , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
	cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VV0.VV0_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VV0.VV0_OPEMOV='2' AND VV0.VV0_SITNFI='1' AND VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
	Do While !( cQAlVV0 )->( Eof() )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
		If nEmpAtu > 0
			cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
		EndIf
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_OPEMOV ) + ( cQAlVV0 )->( VV0_SITNFI ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+( cQAlVV0 )->( VV0_SERNFI ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert("Nenhuma Transferencia de Veiculo para o Chassi"+" "+cLevChas,STR0010)//Nenhuma Transferencia de Veiculo para o Chassi # atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	   	aLevPesq[oLbLevPesq:nAt,03],;
	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	aLevPesq[oLbLevPesq:nAt,05],;
	FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	If !lOk
		oLevChas:SetFocus()
	EndIf
EndIf
Return
