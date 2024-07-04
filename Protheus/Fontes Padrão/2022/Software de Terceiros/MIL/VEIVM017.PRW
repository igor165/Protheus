// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Veivm017.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM017 ³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Remessa de  Veiculos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM017()

Local aArea    := GetArea()

Private oGetMGet1
Private cEstCli, cObserv, oLbParc, oNomCli
Private cTipPag, cDesPag, cDesBco, cCodBco
Private cTipPag1,cLocVei
Private aIndVV0    := {}
Private bFiltraBrw := {|| Nil}
Private cGruVei    := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private cTipOpe    := 3
Private lTroco     := .f.
Private cSerOri    := ""
Private cNfiOri    := ""
Private cIteNFOri  := ""
Private lBaseIcm   := .t.
Private lValIcm    := .t.
Private nc         := 1
Private nUsadoC    := 1
Private nTotalEnt  := 0
Private aIteParc   := {{cTod(""),0}}
Private cCondic1   := ctod(" ")
Private cCondic2   := space(02)
Private cCondic3   := space(02)
Private cCondic4   := space(02)
Private cCondic5   := "1"
Private lJaGrv     := .f.
Private cAlias     := "VV0"
Private cParPrg    := "3" // Faturamento
Private cTipSai    := "3" // Remessa
Private aMemos     := {{"VVA_OBSMEM","VVA_OBSERV"}}
Private aTipFat    := {OemToAnsi(STR0025),OemToAnsi(STR0026)}
Private aColsC     := {}
Private aHeaderC   := {}
Private aGravaEnt  := {}
Private cNumLib    := " " // Para Liberacao de Venda
Private nValCor    := 0
Private cSimVda    := "V"
Private cPrefNF    := ""
Private cPrefix    := GetNewPar("MV_PREFVEI","VEI")
Private cEstoque   := "S"
Private nValEqp    := 0
Private nTotEnt    := 0
Private cSitVei    := "03"
Private aCampoVV1  := {}
Private lTelVdaSim := lValGeral := lDigVda := lReserv := lTelSim := lCarDad := lFecTel := .f.
Private nAliIss    := GETMV("MV_TXISS")  / 100
Private nAliPis    := GETMV("MV_TXPIS")  / 100
Private nAliCof    := GETMV("MV_TXCOFIN")/ 100
Private lA1_IBGE   := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE   := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
Private cTipoMov   := "R"
Private lMsHelpAuto:= .f.
Private lMsErroAuto:= .f.
Private lAbortPrint:= .f.
Private aRotina    := MenuDef()
Private cNota      := cNumero := ""
Private cSerie     := ""
Private cCpoDiv    := "    1"
Private lMudouNum  := .f.

Private aNewBot    := {{"PRECO",{|| FS_VLSAIRE() },"Valor Venda Da Tabela Preços"}}   //Boby - FNC 28324

&& Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(11,14,41)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro  := OemToAnsi(STR0027)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
cIndex    := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao :='VV0_OPEMOV $ "36" .and. VV0_SITNFI <> "0"' // Remessa e Ret. Remessa nao Cancelados

bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
Eval(bFiltraBrw)

aCores := {{'VV0->VV0_OPEMOV == "3" .AND. VV0->VV0_SITNFI == "1"','BR_VERDE'},;
{'VV0->VV0_OPEMOV == "6" .AND. VV0->VV0_SITNFI == "1"','BR_AMARELO'},;
{'VV0->VV0_OPEMOV == "3" .AND. VV0->VV0_SITNFI <> "1"','BR_PRETO'}}

mBrowse( 6, 1,22,75,"VV0",,,,,,aCores)

dbSelectArea("VV0")
RetIndex("VV0")
dbClearFilter()
aEval(aIndVV0,{|x| Ferase(x[1]+OrdBagExt())})
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_REMESSA³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Remessa de Veiculos                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_REMESSA(cAlias, nReg_, nOpc_)

Local oDlgFolder, ni
Local oDlg
Local oFont
Local cPrimeiro:= ""
Local nRecno   := Recno()
Local nOrdem   := IndexOrd()
Local nControl := 0
Local nOk      := 0
Local aPages   := {}
Local aVar     := {}
Local aTitles  := {OemToAnsi(STR0028)}
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0

Private cTipR

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private nTotalEnt := 0
Private cIdeSB6   := ""
Private cChaInter := ""
Private aAcols    := {}
Private nReg      := nReg_
Private nOpc      := nOpc_

Private nAcresFin := 0 // Cria Variavel para compatib. com o VEIVM011

cLocVei := GETMV("MV_LOCVEIN")
if VV1->VV1_ESTVEI == '1'
	cLocVei := GETMV("MV_LOCVEIU")
Endif

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
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV0_CODCLI/VV0_LOJA/VV0_NOMCLI/VV0_CODVEN/VV0_NOMVEN/VV0_CHASSI/VV0_CHAINT/VV0_DESMAR/VV0_DESGRU/VV0_DESMOD/VV0_FABMOD/VV0_PLAVEI/VV0_VALMOV/VV0_FORPAG/VV0_DESFPG/VV0_CODTES/VV0_VBAICM/VV0_ALIICM/VV0_TOTICM/VV0_OBSERV/VV0_OBSMEM/VV0_CODTRA/VV0_TPFRET"
		AADD(aPriEnc,x3_campo)
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
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
Private lExclui := nOpc == 4

if lExclui
	if !Empty(VV0->VV0_TRADEV)
		MsgStop(STR0029 ,STR0017) //Para cancelar primeiro cancele o retorno da remessa... - Atencao!
		Return .f.
	Endif
Endif

//Zera as variaveis fiscais
MaFisEnd()

lTelVdaSim := lJaGrv := .f.
if nOpc <> 2 .and. !lExclui
	nOpc1 := 0
	cTipR := " "
	DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0005) FROM  02,04 TO 8,28 OF oMainWnd   //"Tipo de Inclusao"
	
	nCkPerg1 := 1
	@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
	OemToAnsi(STR0003), OemToAnsi(STR0004);
	OF oDlgPerg PIXEL
	
	@ 028,005 BUTTON oOkBt  PROMPT OemToAnsi(STR0030) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpc1 := 1,oDlgPerg:End())//Confirma
	@ 028,048 BUTTON oNoBt  PROMPT OemToAnsi(STR0031) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpc1 := 2,oDlgPerg:End())//Cancela
	
	oOkBt:SetFocus()
	
	ACTIVATE MSDIALOG oDlgPerg CENTER
	
	if nOpc1 <> 1
		cCondicao :='VV0_OPEMOV $ "36" .and. VV0_SITNFI <> "0"' // Remessa e Ret. Remessa nao Cancelados
		Return(.t.)
	Endif
	
	cTipR := str(nCkPerg1,1)
	
	cTipSai   := "3" // Saida Por Remessa
	
	if cTipR == "2"
		
		//Browse das entradas por Remessa
		cTipSai   := "6" // Retorno da Entrada por Remessa
		cCondicao :='VVF->VVF_OPEMOV == "2" .and. VVF->VVF_SITNFI == "1" .and. Empty(VVF->VVF_NUMTRA)'
		aIteBrw   := {}
		
		dbSelectArea("VVF")
		dbSetOrder(1)
		dbSeek(xFilial("VVF"))
		While !eof() .and. VVf->VVf_FILIAL == xFilial("VVF")
			if &cCondicao
				aadd(aIteBrw,{.f.,VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_VALMOV,VVF->VVF_TRACPA,VVF->VVF_DATMOV,VVF->VVF_CODFOR,VVF->VVF_LOJA})
			Endif
			dbSelectArea("VVF")
			dbSkip()
		Enddo
		
		if Len(aIteBrw) == 0
			aadd(aIteBrw,{.f.," "," "," "," "," "," "," "})
		Endif
		
		xOpca  := 0
		cOrcto := space(8)
		
		DEFINE MSDIALOG oDlg2 FROM  04,10 TO 34,80 TITLE cCadastro OF oMainWnd
		
		@ 014, 001 LISTBOX oLbHd2 FIELDS HEADER	OemToAnsi(""),;
		OemToAnsi(STR0007 ),;
		OemToAnsi(STR0008),;
		OemToAnsi(STR0009),;
		OemToAnsi(STR0010),;
		OemToAnsi(STR0011),;
		OemToAnsi(STR0012),;
		OemToAnsi(STR0013);
		COLSIZES 10,35,20,35,35,35,40,35;
		SIZE 237,212 OF oDlg2 PIXEL ON DBLCLICK (FS_CLRM(oLbHd2:nAt))
		oLbHd2:Align := CONTROL_ALIGN_ALLCLIENT
		
		oLbHd2:SetArray(aIteBrw)
		oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
		aIteBrw[oLbHd2:nAt,2] ,;
		aIteBrw[oLbHd2:nAt,3] ,;
		FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,4],"@E 99,999,999.99"))	,;
		aIteBrw[oLbHd2:nAt,5] ,;
		aIteBrw[oLbHd2:nAt,6] ,;
		aIteBrw[oLbHd2:nAt,7] ,;
		aIteBrw[oLbHd2:nAt,8] }}
	
		ACTIVATE MSDIALOG oDlg2 CENTER ON INIT (FG_EnchoiceBar(oDlg2,{|| xOpca := 1, oDlg2:End() }, {|| xOpca := 2,oDlg2:End() } ))
		
		if xOpca <> 1
			cCondicao :='VV0_OPEMOV $ "36" .and. VV0_SITNFI <> "0"' // Remessa e Ret. Remessa nao Cancelados
			Return(.f.)
		Endif
		
	Endif
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
aCpoEncS := {}
aCpoEncI := {}
While !Eof().and.(x3_arquivo=="VV0")
	if Inclui
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	DbSkip()
EndDo
ConfirmSx8()

if !Inclui
	RegToMemory("VV0",.f.)
	DbSelectArea("VV0")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aAcols da GetDados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VVA")
While !Eof().And.(x3_arquivo=="VVA")
	if Inclui
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	DbSkip()
End

if nOpc # 3
	dbSelectArea("VV0")
	dbGoto(nReg_)
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
	dbSelectArea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	M->VV0_CODTES := VVA->VVA_CODTES
	M->VV0_CHAINT := VVA->VVA_CHAINT
	M->VV0_CHASSI := VVA->VVA_CHASSI
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+M->VV0_CHAINT)
	
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
	
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
	M->VV0_PLAVEI := VV1->VV1_PLAVEI
	
Endif

lValGeral:= .T.
cTipFat  := "0"
cNovUsa  := cTipFat
dDatMov  := dDatEmi := dDataBase

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

dbSelectArea("SA3")
dbSetOrder(1)
if type("Inclui") == "U" .or. Inclui .or. (!Inclui .and. Empty(VV0->VV0_CODVEN))
	dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
	M->VV0_CODVEN := VAI->VAI_CODVEN
	M->VV0_NOMVEN := SA3->A3_NOME
Else
	dbSeek(xFilial("SA3")+M->VV0_CODVEN)
	M->VV0_CODVEN := VAI->VAI_CODVEN
	M->VV0_NOMVEN := SA3->A3_NOME
Endif

if cTipR == "2"
	//Retorno da entrada de veiculo por Remessa
	Private M->VVA_ALIICM := M->VVA_VALVEI := M->VVA_VALMOV := 0
	Private M->VVA_VBAICM := M->VVA_ALIICM := M->VVA_ICMVEN := 0
	Private M->VVA_VALDES := M->VVA_VALVDA := 0
	Private M->VV0_CODCLI := M->VV0_LOJA   := M->VVA_CHAINT := ""
	Private M->VVA_CHASSI := M->VV1_CHAINT := M->VV1_MODVEI := ""
	Private M->VV1_CODMAR := M->VV0_FORPAG := M->VVA_CODTES := ""
	
	FS_RETENT()
	
	Return
Endif

if Str(nOpc,1) $ "24" // Consulta ou Alteracao
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+VV0->VV0_CODCLI))
	cNomCli := SA1->A1_NOME
	cNomVen := cDesMod :=  cDesCor := cDesMar := cDesFpg := cNomBco := Space(15)
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
	M->VV1_CODMAR := VV1->VV1_CODMAR
	M->VV1_MODVEI := VV1->VV1_MODVEI
	
	If !FS_CARDAD(nOpc)
		Return
	Endif
	DbSelectArea("VV0")
	
Else  //Inclusao
	
	M->VVA_ALIICM := val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2))
	M->VVA_VALVEI := M->VVA_VALMOV := M->VVA_VBAICM := M->VVA_ICMVEN := M->VVA_VALDES := M->VVA_VALVDA := nValEqp := 0
	M->VV0_FORPAG := M->VV1_CODMAR := cSerNfi := Space(3)
	M->VV0_LOJA   := M->VV0_LOJAAV:= Space(02)
	M->VVA_CHAINT := M->VV1_CHAINT := Space(12)
	M->VV0_CODCLI := Space(TAMSX3("VV0_CODCLI")[1])
	M->VV1_MODVEI := cNomVen := cDesMod :=  cDesCor := cDesMar := cDesFpg := cNomBco := cNomCli := Space(15)
	M->VVA_CHASSI := Space(25)
	
Endif

cAliasEnchoice   := "VV0"

Private oFolderV
Private oEnc01
Private nOpcao   := nOpc
Private aSvAtela := {{}}
Private aSvAGets := {{}}
Private aTela    := {}
Private aGets    := {}
Private nOpca    := 0
Private lOk      := .F.
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
oGetMGet1:= MsMGet():New("VV0",0,nOpc,,,,aPriEnc,{013,000,203,315},,2,,,,oDlgFolder,,.T.,.F.,"aSvTela[1]",.t.)
oGetMGet1:oBox:bGotFocus   := {|| AL_Entra(1,"VV0") }
oGetMGet1:oBox:bLostFocus  := {|| AL_Sai(1)}
aSvTela[1] := aClone(aTela)
aSvGets[1] := aClone(aGets)

ACTIVATE MSDIALOG oDlgFolder CENTER ON INIT EnchoiceBar(oDlgFolder,{|| Processa({|| Fs_RTudoOk() }),if(nOpca == 1,oDlgFolder:End(),.f.)},{||nOpca := 2,oDlgFolder:End()},,aNewBot)
//aNewBot


dbSelectArea("VV0")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra o Browse de acordo com a condicao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCondicao :='VV0_OPEMOV $ "36" .and. VV0_SITNFI <> "0"' // Remessa e Ret. Remessa nao Cancelados
bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
Eval(bFiltraBrw)

Return


/////////////////////
Function Fs_RTudoOk()

Local lRet := .t.
Local i := 0
nOpca := 2

if nOpc == 2
	nOpca := 1
	Return .t.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rafael - 15/12/2009 - Solicitado Pelo Manoel                 ³
//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aPriEnc)
	If X3Obrigat(aPriEnc[i]) .and. Empty(&("M->"+aPriEnc[i]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aPriEnc[i]),4,1 )
		Return .F.
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Boby - 30/03/2010 - Criar PE para ver se autoriza ou nao a   ³
//³                     confirmação da Remessa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VM017ANF")
	If !ExecBlock("VM017ANF",.f.,.f.)
		Return .F.
	EndIf
EndIf

//Verifica se a Transferencia e para uma outra Filial
dbSelectArea("SA1")

lTelVdaSim := .f.
ProcRegua(6)

if !lExclui .and. (Inclui .or. Altera)
	
	if Empty(M->VV0_FORPAG)
		cTipPag        := RetCondVei()
		M->VV0_FORPAG := cTipPag
	Endif
	
	if VV1->VV1_SITVEI $ "124" .and. (Inclui .or. Altera) .and. cTipR <> "2"
		Help(" ",1,"VEICJAVEND")
		Return .f.
	Endif
	/*
	if cTipR == "2"
	if SF4->F4_PODER3 <> "D" // Remessa
	MsgInfo("O TES tem que controlar poder de terceiro na DEVOLUCAO!","Atencao!")
	Return .f.
	Endif
	Else
	if SF4->F4_PODER3 <> "R" // Remessa
	MsgInfo("O TES tem que controlar poder de terceiro na REMESSA!","Atencao!")
	Return .f.
	Endif
	Endif
	*/
	
	lMsHelpAuto:= .t.
	lMsErroAuto:= .f.
	
	lJaGrv := .f.
	
	if M->VVA_VALMOV == 0
		M->VVA_VALMOV := M->VV0_VALMOV
	Endif
	if M->VVA_VALVDA == 0
		M->VVA_VALVDA := M->VV0_VALMOV
	Endif
	if cTipR == "2"
		M->VV0_CODTES := get_TES
		M->VV0_CHASSI := get_CHASSI
	endif
	if cTipR == "2"
		M->VV0_OPEMOV := "6"  //Retorno da Entrada por Remessa
	Else
		M->VV0_OPEMOV := "3"  //Remessa Normal
	Endif
	If Empty(M->VV0_CODTES)
		M->VV0_CODTES := GetNewPar("MV_TESREMV","771")
	Endif
	M->VVA_CODTES := M->VV0_CODTES
	nTotEnt := M->VVA_VALVDA
	
	If FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
		
		lOk := .f.
		Return .f.
		
	Else
		
		lOk   := .t.
		cNota := cNumero
		Begin Transaction
		IncProc(STR0002) //Gravando Remessa...
		cNumTra := M->VV0_NUMTRA
		FS_GRAVA010("S",nOpc)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		IncProc(STR0002) //Gravando Remessa...
		FS_GRAVA010("G",nOpc)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VV0->(dbGoTo(VV0->(Recno())))
		VVA->(dbGoTo(VVA->(Recno())))
		//
	    FM_LOCVZL(2)
		FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
	    //
		dbSelectArea("VV0")
		reclock("VV0",.f.)
		VV0_VALTOT := SF2->F2_VALBRUT
		VV0_VBAICM := SF2->F2_BASEICM
		VV0_TOTICM := SF2->F2_VALICM
		msunlock()
		if cTipR == "2"
			For i:=1 to Len(aIteBrw)
				if aIteBrw[i,1]
					dbSelectArea("VVF")
					dbSetOrder(1)
					if dbSeek(xFilial("VVF")+aIteBrw[i,5])
						dbSelectArea("VVG")
						dbSetOrder(1)
						if dbSeek(xFilial("VVG")+aIteBrw[i,5])
							//Grava situacao da NF como DEVOLVIDA
							dbSelectArea("VVF")
							RecLock("VVF",.f.)
							VVF->VVF_SITNFI := "2"
							VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
							MsUnlock()
							Exit
						Endif
					Endif
				Endif
			Next
		Endif
		nOpca := 1
		
		If ExistBlock("VM017DNF")
			ExecBlock("VM017DNF",.f.,.f.)
		EndIf
		
		End Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX6")
		MsRUnLock()
		
		SX5->(MsRUnLock())
		
		if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"	//Integrado com o Sigaloja
			If ExistBlock("NFSAIVEI") .and. nOpca == 1
				IncProc(OemtoAnsi(STR0032))//Imprimindo Nota Fiscal...
				dbSelectArea("VV0")
				Set Filter To
				ExecBlock("NFSAIVEI",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI})
				lEmitiu := .t.
			Endif
		Endif
	Endif
Else
	if lExclui
		If MsgYesNo(OemToAnsi(STR0033),OemToAnsi(STR0017))  //Cancela a Remessa?  - Atencao!
			if VV0->VV0_OPEMOV == "6"
				cTipSai := "6" // Retorno da Entrada por Remessa
			Endif
			
			dbSelectArea("VVA")
			dbSetOrder(1)
			dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
			
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
			
			if VV1->VV1_SITVEI == "1"
				MsgInfo(STR0016,STR0017)
				Return .f.
			Endif
			
			if cTipSai == "6" // Retorno da Entrada por Remessa
				dbSelectArea("VVF")
				dbSetOrder(1)
				if !dbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
					Return .f.
				Endif
			Endif
			
			cTipFat  := "0"
			
			Processa( {|| FS_GRACAN() }," "," ",.t. )
			
			if lMsErroAuto
				lRet := .f.
				MostraErro()
			Else
				nOpca := 1
				dbSelectArea("SB1")
				dbSetOrder(7)
				dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)

				FM_LOCVZL(1)
				FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
			Endif
		Endif
	Endif
Endif

Return(lRet)


//////////////////////
Function FS_CLRM(nPos)

Local i := 0
For i:=1 to Len(aIteBrw)
	aIteBrw[i,1] := .f.
Next

if aIteBrw[nPos,1]
	aIteBrw[nPos,1] := .f.
Else
	aIteBrw[nPos,1] := .t.
Endif

oLbHd2:SetArray(aIteBrw)
oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
aIteBrw[oLbHd2:nAt,2] ,;
aIteBrw[oLbHd2:nAt,3] ,;
FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,4],"@E 99,999,999.99"))	,;
aIteBrw[oLbHd2:nAt,5] ,;
aIteBrw[oLbHd2:nAt,6] ,;
aIteBrw[oLbHd2:nAt,7] ,;
aIteBrw[oLbHd2:nAt,8] }}

oLbHd2:Refresh()

Return


////////////////////
Function FS_RETENT()

Local lRet := .t.
Local i := 0
Local cont

Private oDesTes,oCodTes

For i:=1 to Len(aIteBrw)
	if aIteBrw[i,1]
		dbSelectArea("VVF")
		dbSetOrder(1)
		if dbSeek(xFilial("VVF")+aIteBrw[i,5])
			dbSelectArea("VVG")
			dbSetOrder(1)
			if dbSeek(xFilial("VVG")+aIteBrw[i,5])
				Exit
			Endif
		Endif
	Endif
Next

nValEqp := 0
cNomVen := ""
cDesMod := ""
cDesCor := ""
cDesMar := ""
cDesFpg := ""
cNomBco := ""
cNomCli := ""

M->VVA_NUMTRA := M->VV0_NUMTRA
M->VVA_ALIICM := val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2))
M->VVA_VALVEI := VVG->VVG_VALUNI
M->VVA_VALMOV := VVF->VVF_VALMOV
M->VVA_VBAICM := VVG->VVG_VBAICM
M->VVA_ALIICM := VVG->VVG_ALIICM
M->VVA_ICMVEN := VVG->VVG_ICMCOM
M->VVA_VALDES := VVG->VVG_VALDES
M->VVA_VALVDA := VVF->VVF_VALMOV

dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+VVG->VVG_CHASSI)

M->VVA_CHAINT := VVG->VVG_CHAINT
M->VVA_CHASSI := VV1->VV1_CHASSI
M->VV1_CHAINT := VVG->VVG_CHAINT
M->VV1_MODVEI := VV1->VV1_MODVEI
M->VV1_CODMAR := VV1->VV1_CODMAR

M->VV0_CHASSI := VV1->VV1_CHASSI
M->VV0_CHAINT := VV1->VV1_CHAINT
M->VV0_FORPAG := VVF->VVF_FORPAG
M->VV0_CODCLI := VVF->VVF_CODFOR
M->VV0_LOJA   := VVF->VVF_LOJA
M->VV0_VALMOV := VVF->VVF_VALMOV

dbSelectArea("SA2")
dbSetOrder(1)
if dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	
	VVR->(dbSetOrder(2))
	VVR->(dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD))
	
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0034) FROM  02,06 TO 23,78 OF oMainWnd //Dados da Devolucao
	
	@ 013,000 SCROLLBOX oScroll VERTICAL SIZE 130,286 OF oDlg BORDER PIXEL
	oScroll:Align:=CONTROL_ALIGN_ALLCLIENT
	
	aFields := {{"CODFOR",STR0035     ,"C",TamSx3("VV0_CODCLI")[1],TamSx3("VV0_CODCLI")[1],"@!",.f.,,,,CLR_HBLUE},;//Fornecedor
	{"LOJA"  ,RetTitle("VV0_LOJA"),"C",TamSx3("VV0_LOJA")[1]  ,TamSx3("VV0_LOJA")[1]  ,"@!",.f.,,,,CLR_HBLUE},; //Loja
	{"NOMCLI",RetTitle("VV0_NOMCLI"),"C",TamSx3("VV0_NOMCLI")[1],60,"@!",.f.,,,,CLR_BLACK},;//Nome
	{"CHASSI",RetTitle("VV0_CHASSI"),"C",TamSx3("VV0_CHASSI")[1],60,"@!",.f.,,,,CLR_HBLUE},; //Chassi
	{"CHAINT",RetTitle("VV0_CHAINT"),"C",TamSx3("VV0_CHAINT")[1],TamSx3("VV0_CHAINT")[1],"@!",.f.,,,,CLR_BLACK},; //Chassi Interno
	{"MARCA" ,RetTitle("VV0_CODMAR"),"C",TamSx3("VV0_CODMAR")[1],40,"@!",.f.,,,,CLR_BLACK},;//Marca
	{"GRUPO" ,RetTitle("VV0_GRUMOD"),"C",TamSx3("VV0_GRUMOD")[1],60,"@!",.f.,,,,CLR_BLACK},;//Grupo Modelo
	{"MODELO",RetTitle("VV0_MODVEI"),"C",TamSx3("VV0_MODVEI")[1],60,"@!",.f.,,,,CLR_BLACK},;//Modelo
	{"COR"   ,RetTitle("VV0_DESCOR"),"C",TamSx3("VV0_DESCOR")[1],40,"@!",.f.,,,,CLR_BLACK},;//Cor
	{"FABMOD",RetTitle("VV0_FABMOD"),"C",TamSx3("VV0_FABMOD")[1],TamSx3("VV0_FABMOD")[1],"@R 9999/9999",.f.,,,,CLR_BLACK},;//Fab/Mod
	{"PLAVEI",RetTitle("VV0_PLAVEI"),"C",TamSx3("VV0_PLAVEI")[1],TamSx3("VV0_FABMOD")[1],"@!",.f.,,,,CLR_BLACK},;//Placa
	{"VALOR" ,RetTitle("VV0_VALMOV"),"C",TamSx3("VV0_VALMOV")[1],35,"@E 999,999,999.99",.f.,,,,CLR_HBLUE},;//Valor Movimento
	{"TES"   ,RetTitle("VV0_CODTES"),"C",TamSx3("VV0_CODTES")[1],TamSx3("VV0_CODTES")[1],"@!",.t.,"VALTES17(get_TES)","SF4",,CLR_HRED},;//TES
	{"CODTRA",RetTitle("VV0_CODTRA"),"C",TamSx3("VV0_CODTRA")[1],10,"@!",.t.,"Vazio() .or. ExistCPO('SA4')","SA4",,CLR_BLACK}}
	
	for cont := 1 to Len(aFields)
		&("o_"+aFields[cont,1]) := Nil
	next
	
	for cont := 1 to Len(aFields)
		if aFields[cont,3] == "C"
			&("get_"+aFields[cont,1]) := space(aFields[cont,4])
		Elseif aFields[cont,3] == "D"
			&("get_"+aFields[cont,1]) := ctod("")
		Else
			&("get_"+aFields[cont,1]) := 0
		Endif
	next
	
	EnchoiceTemp(oScroll, aFields)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 31/08/2009                         ³
	//³Adiciona o Combo do Tipo do Frete por ultimo³
	//³FNC 18018/2009                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->(dbSetOrder(2))
	SX3->(dbSeek("VV0_TPFRET"))
	aTPFRETE := FormatIN(" ;" + AllTrim(X3CBOX()),";")
	aTPFRETE := StrTran(aTPFRETE,"(","{")
	aTPFRETE := StrTran(aTPFRETE,")","}")
	aTPFRETE := &(aTPFRETE)
	get_TPFRETE := Space(TAMSX3("VV0_TPFRET")[1])
	@ ((Int(Len(aFields)/2)) * 17)+1 , IIF ( (Len(aFields) % 2) == 0 , 4 , 170 ) SAY RetTitle("VV0_TPFRET") OF oScroll Pixel
	@ ((Int(Len(aFields)/2)) * 17)+8 , IIF ( (Len(aFields) % 2) == 0 , 4 , 170 ) MSCOMBOBOX o_TPFRETE VAR get_TPFRETE SIZE 30,19 ITEMS aTPFRETE OF oScroll PIXEL COLOR CLR_BLACK
	
	get_CODFOR := SA2->A2_COD
	get_LOJA   := SA2->A2_LOJA
	get_NOMCLI := SA2->A2_NOME
	get_CHASSI := VV1->VV1_CHASSI
	get_CHAINT := VV1->VV1_CHAINT
	get_MARCA  := VE1->VE1_DESMAR
	get_GRUPO  := VVR->VVR_DESCRI
	get_MODELO := VV2->VV2_DESMOD
	get_COR    := VVC->VVC_DESCRI
	get_FABMOD := VV1->VV1_FABMOD
	get_PLAVEI := VV1->VV1_PLAVEI
	get_VALOR  := VVF->VVF_VALMOV
	
	for cont := 1 to Len(aFields)
		&("o_"+aFields[cont,1]):Refresh()
	next
	
	o_TES:SetFocus()
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,Iif(VALID017(),oDlg:End(),.t.)},{||nOpca := 2,oDlg:End()})
	
	
	if nOpca <> 1 .or. nOpc == 2
		Return .t.
	Endif
	
Endif

Return

//////////////////
Function VALID017()

if Empty(get_CODFOR)
	MsgInfo(STR0021,STR0022)
	Return .f.
Endif

if Empty(get_TES)
	MsgInfo(STR0023,STR0022)
	Return .f.
Endif

M->VVA_CODTES := get_TES
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 31/07/2009                                              ³
//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
//³FNC 18018/2009                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->VV0_CODTRA := get_CODTRA
M->VV0_TPFRET := get_TPFRETE

dbSelectArea("SD1")
dbSetOrder(1)
if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cNfiOri   := VVF->VVF_NUMNFI
	cSerOri   := VVF->VVF_SERNFI
	cIteNFOri := SD1->D1_ITEM
	cIdeSB6   := SD1->D1_IDENTB6
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
	
	Processa({|| Fs_RTudoOk() })
	
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VALTES17  ³ Autor ³  Andre                ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do TES digitado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VALTES17(cTes)

Local lRet := .t.

if Val(cTes) < 500
	lRet := .f.
Endif

if SF4->(DbSeek(xFilial("SF4")+cTes))
	if !lRet
		MsgInfo(OemtoAnsi(STR0036),OemtoAnsi(STR0017))	//O TES Informado se refere a uma ENTRADA, informe um TES correto de SAIDA... - Atencao!
	Endif
Else
	lRet := .f.
Endif

if lRet
	if SF4->F4_ESTOQUE == "N"
		// Manoel - 17/02/2005
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
		If VV1->VV1_SITVEI != " "
			MsgInfo(STR0024,STR0022)
		Endif
	Endif
	
	//if SF4->F4_PODER3 <> "D" //Devolucao
	//   MsgInfo("O TES tem que controlar poder de terceiro na DEVOLUCAO!","Atencao!")
	//	lRet := .f.
	//Endif
	
	If !MaFisFound('NF')
		If !Empty(M->VV0_LOJA)
			MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'C','N',SA1->A1_TIPO,MaFisRelImp("VEIVM000",{"VVF","VVG"}))
		EndIf
	Else
		FS_FisRef("NF_CODCLIFOR",M->VV0_CODCLI)
		If !Empty(M->VV0_LOJA)
			FS_FisRef("NF_LOJA",M->VV0_LOJA)
		EndIf
	EndIf

  	SB1->(dbSelectArea("SB1"))
	SB1->(dbSetOrder(7) )
  	SB1->(dbSeek(xFilial("SB1")+cGruVei+M->VV0_CHAINT) )
	
	FS_FisRef("IT_VALMERC",M->VV0_VALMOV)
//	FS_FisRef("IT_PRODUTO",M->VV0_CHAINT)	// FNC - 28020/2010 - BOBY - 16/12/10
	FS_FisRef("IT_PRODUTO",SB1->B1_COD)    // Trocado VV1_CHAINT pelo B1_COD, pois a referencia do
                                            // imposto e feito pelo B1_COD.
	FS_FisRef("IT_TES"    ,M->VV0_CODTES)
	FS_FisRef("IT_ALIQICM",M->VV0_ALIICM)

	M->VV0_VBAICM := MaFisRet(,"NF_BASEICM")
	M->VV0_TOTICM := MaFisRet(,"NF_VALICM")
	
	M->VVA_CODTES := M->VV0_CODTES
Endif

Return (lRet)


Function FS_PESQ17()

axPesqui()

cCondicao :='VV0_OPEMOV $ "36" .and. VV0_SITNFI <> "0"' // Remessa e Ret. Remessa nao Cancelados
bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
Eval(bFiltraBrw)

Return

Function FS_ADMCPO17()

if !Empty(M->VV0_CHASSI)
	M->VV0_VALMOV := FS_VALVDA()
Endif

Return .t.

/////////////////////
Function FS_MEMOREM()

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0037) FROM  02,04 TO 14,56 OF oMainWnd //Observacao

DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1

@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
oObserv:bRClicked := {|| AllwaysTrue() }
oObserv:SetFocus()

ACTIVATE MSDIALOG oDlg1 CENTER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_V017LEG | Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Legenda para MBrowse                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_V017LEG()

Local aLegenda := {}

alegenda := {{'BR_VERDE'	,STR0038},;	//Remessa
{'BR_AMARELO'	,STR0039},;	//Retorno da Entrada de Remessa
{'BR_PRETO'	,STR0040}}	//Veiculo de Remessa Normal Retornado

BrwLegenda(cCadastro,STR0041 ,aLegenda)//Legenda

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³GETKEYVEI ³ Autor ³  Andre                ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Apresenta Vados de Veiculos para Orcamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GETKEYVEI(cKey,nTipo)
Local lReturn := .f.
Private cChassi := Alltrim(cKey)
Private aTELA[0][0],aGETS[0]
default nTipo := 0
If Empty(cKey)
	Return(.t.)
EndIf
lReturn := FG_POSVEI("cChassi",)
//dbSelectArea("VV1")
//dbSetOrder(2)
//lReturn := dbSeek(xFilial("VV1")+cKey)
//if !lReturn
//	dbSetOrder(1)
//	lReturn := dbSeek(xFilial("VV1")+cKey)
//Endif
//if !lReturn
//	dbSetOrder(3)
//	lReturn := dbSeek(xFilial("VV1")+cKey)
//Endif
//if !lReturn
//	dbSetOrder(9)
//	lReturn := dbSeek(xFilial("VV1")+cKey)
//Endif
if !lReturn
	MsgInfo(STR0042,STR0017) //Veiculo nao encontrado - Atencao!
Else
	if nTipo == 1
		&(ReadVar()) := VV1->VV1_CHAINT
	ElseIf nTipo = 2
		&(ReadVar()) := VV1->VV1_CHASSI
	ElseIf nTipo = 9
		&(ReadVar()) := VV1->VV1_PLAVEI
	Endif
Endif

Return(lReturn)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |DADOS017  ³ Autor ³  Andre                ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Apresenta Dados de Veiculos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DADOS017()

Local cLocVei := VV1->VV1_LOCPAD
if Type("cTipoMov") <> "C"
	cTipoMov := "N"
Endif

if Empty(VV1->VV1_LOCPAD)
	cLocVei := GETMV("MV_LOCVEIN") //Novo
	if VV1->VV1_ESTVEI == '1'
		cLocVei := GETMV("MV_LOCVEIU") //Usado
	Endif
	if VV1->VV1_SITVEI == "4" //Consignado
		cLocVei := GETMV("MV_LOCVEIC")
	Endif
Endif

M->VV9_CODCLI := M->VV0_CODCLI
M->VV9_LOJA   := M->VV0_LOJA

M->VV0_CHAINT := VV1->VV1_CHAINT
M->VV0_CODMAR := VV1->VV1_CODMAR
M->VV0_MODVEI := VV1->VV1_MODVEI
M->VV0_FABMOD := VV1->VV1_FABMOD
M->VV0_PLAVEI := VV1->VV1_PLAVEI

VE1->(dbSetOrder(1))
VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
M->VV0_DESMAR := VE1->VE1_DESMAR
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
M->VV0_DESMOD := VV2->VV2_DESMOD
VVR->(dbSetOrder(2))
VVR->(dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD))
M->VV0_GRUMOD := VV2->VV2_GRUMOD
M->VV0_DESGRU := VVR->VVR_DESCRI
nValPrepM := VV1->VV1_SUGVDA
if nValPrepM == 0
	FG_Seek("VVP","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV2->VV2_SEGMOD+DTOS(DDATABASE)",1,.t.)
	If VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV2->VV2_SEGMOD == VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD
		If dDataBase < VVP->VVP_DATPRC
			VVP->(DbSkip(-1))
		Endif
		If !(VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV2->VV2_SEGMOD == VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD)
			nValPrepM := 0
		Else
			nValPrepM := VVP->VVP_VALTAB
		Endif
	Else
		VVP->(DbSkip(-1))
		If !(VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV2->VV2_SEGMOD == VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD)
			nValPrepM := 0
		Else
			nValPrepM := VVP->VVP_VALTAB
		Endif
	Endif
endif
dbSelectArea("VVG")
dbSetOrder(1)
if dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	if nValPrepM == 0
		nValPrepM := VVG->VVG_VALUNI
	endif
Endif
M->VV0_VALMOV := nValPrepM

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))

//Verifica se existe saldo para faturar o veiculo
dbSelectArea("SB2")
dbSetOrder(1)
if (!dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei) .or. SB2->B2_QATU <= 0) .AND. M->VV0_TIPFAT != "2"
	MsgInfo(STR0043,STR0017) //Veiculo nao esta no estoque! - Atencao!
	Return(.f.)
Endif

//Traz o TES padrao para esta operacao de saida (S) normal (N)
dbSelectArea("VZA")
dbSetOrder(1)
if dbSeek(xFilial("VZA")+"S"+cTipoMov+iif( Inclui, "0",VV1->VV1_ESTVEI) )
	M->VV0_CODTES := VZA->VZA_CODTES
Endif

Return(.t.)

Static Function MenuDef()
Local aRotina := {{OemtoAnsi(STR0044),"FS_PESQ17", 0 ,1},;         		//Pesquisar
{OemtoAnsi(STR0045)	,"FS_REMESSA", 0, 2},;  	//Consultar
{OemtoAnsi(STR0046) ,"FS_REMESSA", 0, 3},;  	//Incluir
{OemtoAnsi(STR0047) ,"FS_REMESSA", 0, 5},;  	//Cancelar
{OemtoAnsi(STR0048) ,"FS_V017LEG", 0, 0 ,2,.f.},; //Legenda
{OemtoAnsi(STR0049)	,"VM017_LVEI" , 0 , 2}}   	//Pesquisa Chassi
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM017_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 10/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM017_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )
Private oAmar := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oPret := LoadBitmap( GetResources() , "BR_PRETO" )
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
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0050) FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
@ 003,004 SAY STR0051 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE//Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0052) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End())//SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0053),;//Filial
OemToAnsi(STR0054),;//Dt.Movimento
OemToAnsi(STR0055),;//NF/Serie
OemToAnsi(STR0056),;//Valor
OemToAnsi(STR0057);//Cliente
COLSIZES 10,35,37,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="31",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="61",oAmar,oPret)),;
aLevPesq[oLbLevPesq:nAt,03],;
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
	cQuery += "VV0.VV0_OPEMOV IN ('3','6') AND VV0.VV0_SITNFI<>'0' AND VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV"
	
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
		MsgAlert(STR0058 + cLevChas,STR0017) //Nenhuma Saida de Remessa para o Chassi  - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="31",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="61",oAmar,oPret)),;
	aLevPesq[oLbLevPesq:nAt,03],;
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



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VLSAIRE³ Autor ³ Antonio Carlos (Boby) ³ Data ³ 03/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para chamada do Ponto de entrada para preencher o   ³±±
±±³          ³ valor da venda de acordo com o valor informado na tabela   ³±±
±±³          ³ de precos                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VLSAIRE()

If ExistBlock("PVM017VREM")
	ExecBlock("PVM017VREM",.f.,.f.)
EndIf

Return




