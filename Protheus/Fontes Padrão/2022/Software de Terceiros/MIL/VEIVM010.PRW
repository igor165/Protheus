///////////////
// versao 54 //
///////////////

#include "Veivm010.ch"
#include "Protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM010 ³ Autor ³ Manoel / Andre        ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Simulacao / Proposta / Venda de Veiculos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM010

Local aParPrg  := {OemToAnsi(STR0005),OemToAnsi(STR0102),OemToAnsi(STR0103)}
Local bCampo   := { |nCPO| Field(nCPO) }
Local aIndVV0  := {}
Local cCondicao:= ""
Local aArea    := GetArea()
Local nxi := 0
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
Private cFunJEst := GetNewPar("MV_FUNJEST","") // Nome da Funcao que Calcula o Juros de Estoque
Private oTitVLF
Private oFoto      := LoadBitmap( GetResources(), "MAQFOTO" )
Private oNada      := LoadBitmap( GetResources(), "NADA" )
Private oTik       := LoadBitmap( GetResources(), "LBTIK" )
Private oNo        := LoadBitmap( GetResources(), "LBNO" )
Private oAmarelo   := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oVermelho  := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAzul      := LoadBitmap( GetResources(), "BR_AZUL" )

Private cTitVLF    := OemToAnsi(STR0182)
Private cParPrg    := "2" //Proposta
Private lCalcTot   := .f.
Private lAbortPrint:= .f.
Private oFonte     := TFont():New( "Arial", 6, 12 )

Private cChaAnt    := Space(25)
Set Decimal to 4

DEFINE FONT oFnt1 NAME "Arial" SIZE 08,14 BOLD
DEFINE FONT oFnt2 NAME "Arial" SIZE 08,15 BOLD
DEFINE FONT oFnt3 NAME "Arial" SIZE 08,13 BOLD
DEFINE FONT oFnt4 NAME "Arial" BOLD
DEFINE FONT oFnt5 NAME "Times New Roman" SIZE 10,18 BOLD
DEFINE FONT oFnt6 NAME "Times New Roman" SIZE 07,17 BOLD
DEFINE FONT oFnt7 NAME "Times New Roman" SIZE 07,13 BOLD

/*
nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi("") FROM  02,04 TO 08,28 OF oMainWnd //Tipo de Faturamento

@  02, 02 TO 22,094 LABEL OemtoAnsi(STR0104) OF oDlg PIXEL
@  07, 04 MSCOMBOBOX oParPrg VAR cParPrg SIZE 88,50 FONT oFnt4 COLOR CLR_BLACK ITEMS aParPrg OF oDlg PIXEL

DEFINE SBUTTON FROM 27,24 TYPE 1 ACTION (nOpca := 1,oDlg:End());
ENABLE OF oDlg
DEFINE SBUTTON FROM 27,55 TYPE 2 ACTION (nOpca := 2,oDlg:End());
ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

if nOpca # 1
Return
Endif

//(1) - Simulacao   (2) - Proposta   (3) - Faturamento
cParPrg := Subs(cParPrg,1,1)
*/

// Variaveis para Tela de Venda / Simulacao
Private cEstoque,cDesMar,cDesMod,cDesCor,nValCor,cTipFat,nAliIss,nAliIssFD
Private nAliPis,nAliCof,cOutMoed,cObserv,dDatMov,cEstCli,cDesFpg
Private cNomVen,oNomCli,cNomAva,cNomCon,cChaInter,cNomBco,cCodFor,cNomFor,cEmiBlo,cCodMap
Private nValSCor,cTipPag,cDesPag,oCodCli,cNomAGF,cDesTpV, cTransp, cNomCFtd,cNomAli, oPerDes

// Variaveis para Resultado da Avaliacao
Private cTipAva  := "1"   //Veiculos
Private cCpoDiv  := "    1"
Private aStru    := {}
Private aStruLb  := {}
Private aIteDesp := {}
Private aIteRece := {}
Private cSimVda  := "V"
Private cMoedCor := cOutMoed := GetMv("MV_SIMB1")
Private cSimOMoe := 1

// Variaveis para o Filtro do Veiculo
Private oMarcaF , oModeloF, oCorF, oCombus, oValFxI, oValFxF, oAnoIni, oAnoFin, oKMFxa, oTipCor, oGruMod, oGruCor,  oLBox
Private cCombus, nValFxI, nValFxF, nAnoIni, nAnoFin, lValGeral, cTipCor, nKMFxa, cGruCor, cGruMod
Private cEstVeiF := ""
Private cCodMar  := Space(3)
Private cModVei  := Space(10)
Private cCor     := Space(6)
Private cDesTvd  := Space(10)

//Variaveis da Tela de Acessorios
Private bOk
Private cGruIte
Private oAcesso
Private nUsadoEq
Private oValMov, oLbxSerie, oLbxOpc
Private aSerie := {{"",""}}
Private aOpc   := {{"","",0,0}}

dbSelectArea("VVT")
For nxi:=1 to FCount()
	&("M->"+(EVAL(bCampo,nxi))) := " "
Next
M->VVT_DESITE    := ""
Private lPriVez  := .t.
Private cGruFor  := "01"
Private lVV6     := .f.
Private nEq      := 1
Private aColsEq  := {}
Private aHeaderEq:= {}
Private nValEqp  := 0
Private nCusAce  := 0
Private cPrefNF  := ""
Private cPrefix  := GetNewPar("MV_PREFVEI","VEI")
Private nParamet := 1
Private cNumBord := ""
Private dDatBord := cTod("")

// Variaveis Gerais
Private oFolderV
Private oFolder2
Private cNovUsa
Private cArqTrab
Private nOpcMnu
Private cLocVei
Private nIndexVV0
Private aEstoque, aTipFat, aOutMoed
Private nReg      := 0
Private aCols     := {}
Private aHeader   := {}
Private cNumLib   := " " // Para Liberacao de Venda
Private nValLib   := 0
Private cNumPed   := ""
Private aStruVV1  := {}
Private aErrAva   := {}
Private nOpca1    := 1
Private cAlias    := "VV0"
Private aMemos    := {{"VVA_OBSMEM","VVA_OBSERV"}}
Private aRotina   := MenuDef()
Private aHeaderC  := {}
Private aGravaEnt := {}
Private cTipSai   := "0" // 0 = Venda (porem, pode ser transformada em simulacao e vice-versa)
Private aCampoVV1 := {}
Private cCodBco   := ""
Private nTotEntr  := 0
Private cIdeSB6   := Space(6)
Private cSitVei   := "0"
Private cNota     := ""
Private cSerie    := ""
Private cGruVei   := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private cNomCli, cEndCli, cCGCCPF, cPicture, oChk0, oChk1, oChk2, lVar0, lVar1, lVar2, oTotEntr
Private lTelVdaSim:= lDigVda := lReserv := lTelSim := lCarDad := lFecTel := lJaGrv := lDeleta := lWhenCus := .f.
Private bFiltraBrw := {|| Nil}
Private aCampos    := {}

cCadastro  := OemToAnsi(STR0105)

#IFDEF TOP
	dbSelectArea("VV0")
	set filter to
	dbSelectArea("VVA")
	set filter to
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
RetIndex()
dbSetOrder(1)
cCondicao  := ""
bFiltraBrw := {|| FilBrowse("VV0",@aIndVV0,@cCondicao) }
Eval(bFiltraBrw)
mBrowse( 6, 1,22,75,"VV0",,,,"VV0->VV0_OPEMOV == '0' .and. Empty(VV0->VV0_NUMNFI) .and. Empty(VV0->VV0_PESQLJ)")

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
±±³Fun‡„o    ³FS_SIMVDAT³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Simulacao de Venda de Veiculos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SIMVDAT(cAlias, nReg, nOpc_)

Local oChassi, oMarca , oDesMar, oModelo, oDesMod, oCor   , oDesCor , oValVei ,;
oAliIcm, oValCor, oVbaIcm, oValCus, oTipFat, oAliIss, oNumtra , oRecTec ,;
oCodInd, oDesCli, oJurEst, oRedCus, oPiCoRT, oISSRT , oOutMoed, oCodTes ,;
oIcmRet, oObserv, oValDes, oCodBco, oCodAge, oCodAva, oCliAli , oAutFat ,;
oCodVen, oTipVen, oNumNfi, oSerNfi, oForPag, oVCarcr, oEmpCon , oCodGru ,;
oNumCot, oValTot, oNfiOri, oSerOri, oCodFor, oCodMap, oEqpIns , oLojaCli,;
oLojaAva,oLojaFor,oValSCor,oCusAce, oLojAli, oAgeFin, oDatRcu , oDatRtc ,;
oDatDcl, oDatBfb, oTransp

Local ni
Local oFont
Local aTitles, aTitles2, aTitles3
Local cPrimeiro:= ""
Local nControl := 0
Local nOk      := 0
Local aPages   := {}
Local aPages2  := {}
Local aPages3  := {}
Local aVar     := {}
Local nRecno   := Recno()
Local nOrdem   := IndexOrd()
Local bCampo4  := { |nCPO| Field(nCPO) }
Local nCntFor,_ni  := 0
Private nEq      := 1
Private nIC      := 1
Private aColsEq  := {}
Private aHeaderEq:= {}
Private aColsIC  := {}
Private aHeaderIC:= {}
Private nUsadoEq := 0
Private nUsadoIC := 0
Private lTroca   := .f. //Troca com Troco

aColsC    := {}
aHeaderC  := {}
aGravaEnt := {}

MaFisEnd()
dbSelectArea("VV0")
RetIndex("VV0")

// Variaveis para a Condicao de Pagto
Private nOpca
Private cTipPag1
Private oScroll, odlgfold, oObjTel, oCodCDCI
Private ocondic, oGetCondicao, oTotEnt,  oTipPag, oDesPag, oLbParc
Private nC := nV := nS := 1
Private cCodCDCI  := Space(4)
Private aColsV    := {}
Private aHeaderV  := {}
Private cTipOpe   := 3  //Veiculos
Private nTotEnt   := 0
Private nTotalEnt := 0
Private cLinOk1   := "AllwaysTrue()"
Private cTudoOk1  := "AllwaysTrue()"
Private cFieldOk1 := "FG_DADOSENT(nTotEnt),FG_MEMVAR()"
Private aIteParc  := {{cTod(""),0}}
Private cTipPag   := Space(3)
Private cDesPag   := Space(20)
Private aColsC    := {}
Private aHeaderC  := {}
Private aGravaEnt := {}
Private cCondic1  := ctod(" ")
Private cCondic2  := Space(02)
Private cCondic3  := Space(02)
Private cCondic4  := Space(02)
Private cCondic5  := "1"
Private nUsadoC   := 0
Private nValorCom := 0
Private lMntTel   := .f.
Private nAbaAnt   := 1
Private nOpc      := nOpc_
Private lOk       := .f.
nCusAce := nCusCorr := nValCorrec := 0
Private aNewBot   := {{"FILTRO",{|| FS_FILCONS() },STR0318},{"AUTOM" ,{|| FS_FICHAVEI(cOutMoed,3,"V",cTipSai) },STR0319},{"MAQFOTO",{|| FS_FOTO() },STR0320}}   //Filtra Veiculos - Avaliacao de Resultado - Foto do veiculo
Private aSvAtela
Private aSvAGets
Private aSvtela
Private aSvGets

Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oPreto   := LoadBitmap( GetResources(), "BR_PRETO" )
Private oAzul    := LoadBitmap( GetResources(), "BR_AZUL"  )
Private oBranco  := LoadBitmap( GetResources(), "FOLDER9" )

lWhenPD   := .t.
lEntFDI   := .t.
lFecTel   := .f.
lJaGrv    := .f.
lPrivez   := .t.
cCodMar   := Space(3)
cChaInter := " "
aCpoEncS  := {}
aCpoEncI  := {}

cNumTra := ""
if nOpc <> 3
	cNumTra := VV0->VV0_NUMTRA
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
aPriEnc := {}
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !AllTrim(x3_campo) $ "VV0_OPEMOV/VV0_NUMPED/VV0_NUMNFI/VV0_SERNFI/VV0_AUTFAT/VV0_TRADEV/VV0_DEVTRA/VV0_DTHEMI/VV0_FORPAG/VV0_DESFPG/" .and.;
		!AllTrim(x3_campo) $ "VV0_CLIFTD/VV0_LOJFTD/VV0_NNFFDI/VV0_SNFFDI/VV0_NUMLIB/VV0_EXPVEI/VV0_DATEMI/VV0_CODBCO/VV0_CODAGE/VV0_AGEFIN/VV0_SITNFI/VV0_ALIICM/VV0_VBAICM/VV0_TOTICM/" .and.;
		!AllTrim(x3_campo) $ "VV0_MODVDA/VV0_DPGFAB/VV0_DPGVEN/VV0_VALNEG/VV0_CRECON/VV0_SEQVIS/VV0_CODTES/VV0_OBSERV/VV0_OBSMEM"
		
		AADD(aPriEnc,x3_campo)
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

dbSelectArea("SX3")
dbSeek("VVA")
aSegEnc := {}
While x3_arquivo == "VVA" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !AllTrim(x3_campo) $ "VVA_NUMTRA/VVA_TRACPA/VVA_CODORI/VVA_CMFPGC/VVA_FMFTOT/VVA_VMFMOV/VVA_VMFVDA/VVA_VMFCVD/VVA_CMFCOT/VVA_CMFCTP/VVA_RMFTEC" .and.;
		!AllTrim(x3_campo) $ "VVA_BMFFAB/VVA_TMFIMP/VVA_IMFVEN/VVA_IMFCVD/VVA_PMFVEN/VVA_CMFVEN/VVA_IMFRTE/VVA_IMFBFB/VVA_PMFRTE/VVA_PMFBFB/VVA_TMFCUS/VVA_VMFVEI/VVA_IMFCOM/VVA_PMFENT" .and.;
		!AllTrim(x3_campo) $ "VVA_CMFENT/VVA_JMFEST/VVA_RMFCUS/VVA_AMFSSO/VVA_VMFSCO/VVA_LMFBRU/VVA_TMFDES/VVA_DMFCLI/VVA_SMFVIA/VVA_VMFASS/VVA_VMFREV/VVA_VMFFRE/VVA_DMFVEI/VVA_RMFVEI/VVA_VALDES" .and.;
		!AllTrim(x3_campo) $ "VVA_AMFIMP/VVA_LMFLQ1/VVA_DMFFIX/VVA_VMFIRF/VVA_CMFVDE/VVA_CMFGER/VVA_CMFPAT/VVA_DMFFIN/VVA_LMFLQ2/VVA_COMPGC/VVA_ESTVEI/VVA_CHASSI/VVA_CHAINT/VVA_DESMAR/VVA_DESMOD/VVA_DESCOR/VVA_PLAVEI" .and.;
		!AllTrim(x3_campo) $ "VVA_VALMOV/VVA_VALDES/VVA_INPICO/VVA_VALCVD/VVA_COMCOT/VVA_CODIND/VVA_COMCTP/VVA_TOTIMP/VVA_ISSCVD/VVA_PISVEN/VVA_COFVEN/VVA_VALIRF/VVA_RECVEI" .and.;
		!AllTrim(x3_campo) $ "VVA_ISSRTE/VVA_ISSBFB/VVA_PISRTE/VVA_PISBFB/VVA_TOTCUS/VVA_JUREST/VVA_REDCUS/VVA_FATTOT/VVA_COMGER/VVA_COMVDE/VVA_COMPAT/VVA_USUARI/VVA_LUCLQ1/VVA_LUCLQ2/VVA_ICMCOM/VVA_PISENT/VVA_COFENT"
		
		AADD(aSegEnc,x3_campo)
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While !Eof().and.(x3_arquivo=="VV0")
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

if Inclui
	ConfirmSx8()
Else
	dbSelectArea("VV0")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo4,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
if Inclui
	While !Eof().and.(x3_arquivo=="VVA")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		dbSkip()
	EndDo
Else
	dbSelectArea("VVA")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo4,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV1")
if Inclui
	While !Eof().and.(x3_arquivo=="VV1")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		dbSkip()
	EndDo
Else
	VV1->(dbSetOrder(1))
	if VV1->(dbSeek(xFilial("VV1")+M->VVA_CHAINT))
		dbSelectArea("VV1")
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo4,nCntFor)) := FieldGet(nCntFor)
		Next
	Endif
Endif

Do Case
	Case nOpc == 4 //Alterar
		nOpcE:=3
		nOpcG:=3
		cTipFat := VV0->VV0_TIPFAT
		//		M->VV0_SEQVIS := VV0->VV0_SEQVIS
	Case nOpc == 3 //Incluir
		nOpcE:=3
		nOpcG:=3
	Case nOpc == 2 //Visualizar
		nOpcE:=2
		nOpcG:=2
		cTipFat := VV0->VV0_TIPFAT
	Case nOpc == 1 //Pesquisar
		nOpcE:=1
		nOpcG:=1
	Otherwise //Cancelar
		nOpcE:=5
		nOpcG:=5
EndCase

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS9")
aHeaderC:={}
nUsadoC := 0
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_ENTRAD")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for alteracao traz valores digitados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsC   := {}
aIteParc := {}
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+M->VV0_NUMTRA+"V") .and. cTipFat != "2"
	While !Eof() .and. VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VV0->VV0_NUMTRA+'V'
		If VS9->VS9_TIPPAG == "DP"  //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG)
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,08))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,02)
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
			AADD(aColsC,Array(nUsadoC+1))
			For _ni:=1 to nUsadoC
				aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
			Next
			aColsC[Len(aColsC),nUsadoC+1]:=.F.
		Endif
		dbSkip()
	Enddo
Endif

if Len(aColsC) == 0
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Endif

if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif

aCombus  := {OemToAnsi(""),OemToAnsi(STR0120),OemToAnsi(STR0121),OemToAnsi(STR0122),OemToAnsi(STR0123),OemToAnsi(STR0124)}
aTipCor  := {OemToAnsi(""),OemToAnsi(STR0125),OemToAnsi(STR0126),OemToAnsi(STR0127)}
aEstVeiF := {OemToAnsi(""),OemToAnsi("0-"+STR0316),OemToAnsi("1-"+STR0317)}//Novo - Usado
nValFxI  := nValFxF := nKMFxa := 0
nAnoIni  := nAnoFin := 0
cGruCor  := Space(02)
cGruMod  := Space(06)
cDesGMod := cDesGCor := Space(20)
cTipFat  := Space(01)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da Consulta de Veiculos                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oProprietario,oNtTerceiro,oCondPgt,oSituacao,oTerceiro,oPlaca,oKm,oDias

cProprietario := ""
cSituacao     := ""
cCondPgt      := ""
cTerceiro     := ""
cPlaca        := ""
cKm           := ""
nDiasEst      := 0
cNtTerceiro   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 0=Normal Novo , 1=Normal Usado , 2=Faturamento Direto       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTipFat  := {OemToAnsi(STR0016),OemToAnsi(STR0017),OemToAnsi(STR0018)}

aCatVen := {}
nTam    := 0
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_CATVEN")
cCatVen := X3CBOX()
While len(cCatVen) > 1
	nTam := If(at(";",cCatVen)==0,len(cCatVen)+1,at(";",cCatVen))
	aAdd(aCatVen,substr(cCatVen,1,1)+"-"+substr(cCatVen,3,nTam-3))
	cCatVen := Alltrim(substr(cCatVen,nTam+1,len(cCatVen)))
EndDo
DbSetOrder(1)

aTransp  := {OemToAnsi(STR0128),OemToAnsi(STR0129)}

if nOpc = 3
	cTipFat  := ""
	cEstoque := "S"
else
	cTipFat := VV0->VV0_TIPFAT
	cCodBco := VV0->VV0_CODBCO
	cTipPag := VV0->VV0_FORPAG
	M->VV0_CODBCO := VV0->VV0_CODBCO
Endif

if cTipFat == "2"
	cTexto := STR0185
Else
	cTexto := OemToAnsi(STR0119)
Endif
aTitles := {OemToAnsi(STR0114),cTexto,OemToAnsi(STR0116),OemToAnsi(STR0117)}
aTitles2 := {OemToAnsi(STR0321),OemToAnsi(STR0322)}  //Eqp. Instalados - Campanha
aTitles3 := {OemToAnsi(STR0323),OemToAnsi(STR0324)}  // Dados Gerais - Dados do veiculo

if nOpc == 2 .or. nOpc == 4
	lLevCam := .f.
	lValGeral := nOpc == 4
	FG_Seek("VVA","VV0->VV0_NUMTRA",1,.f.)
	FG_Seek("VV1","VVA->VVA_CHAINT",1,.f.)
	M->VVA_CHASSI := VV1->VV1_CHASSI
	If nOpc == 4 .and. (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
		If !Empty(VV0->VV0_NUMNFI)
			Help(" ",1,"OPERACINVA")
			Return .f.
		Endif
	Endif
	nValCor := 0
	//Carrega Variaveis
	If cEstoque == "N" //Nao Estoque
		lWhenCus := nOpc == 3 .or. nOpc == 4
	Else
		lWhenCus := VV1->VV1_INDCAL == "5"  //Veiculos Pedidos a Fabrica
	Endif
	M->VVA_BONFAB := VVA->VVA_BONFAB
	If FS_CARDAD(nOpc) == .f.
		Return
	Endif
	dbSelectArea("VV0")
	M->VV0_AUTFAT := VV0->VV0_AUTFAT
	M->VVA_ALIPIC := VVA->VVA_ALIPIC
	M->VVA_ALIIPI := VVA->VVA_ALIIPI
	M->VVA_PERDES := VVA->VVA_PERDES
	M->VVA_CODTES := VVA->VVA_CODTES
	M->VVA_VRENET := VVA->VVA_VRENET
	M->VVA_PERCVD := VVA->VVA_PERCVD
	M->VV0_VALMOV := VV0->VV0_VALMOV
	cNumLib := VV0->VV0_NUMLIB
	nValLib := VVA->VVA_VALMOV
	//Detalhes dos clientes
	FS_VMCLI010()
	//Detalhes do vendedor
	FS_VMVEND010()
	//Detalhes do veiculo
	FS_VMVEI010()
	//Detalhes do valor do movimento
	FS_VALMOVTO()
Else   //Inclusao
	
	lLevCam := .t.
	nCusAce := nCusCorr := nValCorrec := 0
	nValCor := 0
	dDatMov := dDataBase
	cDesMod := cDesCor := ""
	cDesFpg := cDesMar := Space(20)
	cNomcli := cNomAva := 	cNomAli := 	cNomVen := Space(15)
	
	M->VVA_ALIIPI := 5
	M->VV0_DATEMI := dDataBase
	M->VV0_DPGFAB := cTod("  /  /  ")
	//M->VVA_ALIICM := Val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2)) FNC - 28020/2010 - BOBY - 16/12/10
	Iif(!FM_PILHA("VEIVM017"),M->VVA_ALIICM := Val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2)) ,  M->VVA_ALIICM := M->VV0_ALIICM)
	M->VVA_ALIPIC := GETMV("MV_TXPIS") + GETMV("MV_TXCOFIN")
	M->VVA_PERDES := M->VVA_VALASS := M->VVA_RECTEC := M->VVA_BONFAB := M->VVA_DESCLI := M->VVA_JUREST := M->VVA_REDCUS := 0
	M->VVA_VRENET := M->VVA_VALREV := M->VVA_VALVDA := M->VVA_VCAVEI := M->VVA_VALMOV := M->VVA_ACESSO := M->VVA_VBAICM := 0
	M->VVA_PERCVD := M->VVA_VALFRE := M->VVA_ICMVEN := M->VV0_VCARCR := M->VVA_VALDES := M->VV0_DESACE := M->VVA_SEGVIA := 0
	M->VVA_CODIND := M->VV0_TIPVEN := M->VV0_EMPCON := M->VV0_LOJA := Space(02)
	M->VV0_LOJAAV := M->VV0_LOJALI := M->VV0_LOJFTD := Space(02)
	M->VV1_CODMAR := M->VVA_CODTES := M->VV0_FORPAG := Space(03)
	M->VV0_CODBCO := M->VV0_AGEFIN := M->VV0_SNFFDI := Space(03)
	M->VV0_NUMCOT := Space(04)
	M->VV0_CODAGE := Space(05)
	M->VV0_CODGRU := M->VVA_CHAINT := M->VV0_CODCLI := M->VV0_CODAVA := Space(06)
	M->VV1_CORVEI := M->VV0_CODVEN := M->VV0_CODAVA := Space(06)
	M->VV0_CLIALI := M->VV0_NUMPED := M->VV0_CODTRA := Space(06)
	M->VV0_CLIFTD := M->VV0_NNFFDI := Space(06)
	M->VV0_NUMLIB := Space(08)
	M->VV1_MODVEI := Space(10)
	M->VVA_CHASSI := Space(25)
	M->VV0_MODVDA := Space(1)
	
Endif

cObserv := E_MSMM(VVA->VVA_OBSMEM,68)
Private oGetDadosIC

cAliasEnchoice:= "VV0"
cAliasGetD    := "VVA"
cLinOk        := "CheckCols(n,aAcols)"
cFieldOk      := "AllwaysTrue()"
cTudOk        := "AllwaysTrue()"

Private nOpcao := nOpc

If cParPrg == "1"      // Simulacao
	aSvAtela  := {{},{},{},{},{},{}}
	aSvAGets  := {{},{},{},{},{},{}}
Elseif cParPrg == "2" // Proposta/Pedidos
	aSvAtela  := {{},{},{},{},{}}
	aSvAGets  := {{},{},{},{},{}}
Else                  // Faturamento
	aSvAtela  := {{}}
	aSvAGets  := {{}}
Endif

aSvtela  := {{},{}}
aSvGets  := {{},{}}

Private aTela :={}
Private aGets :={}
Private oEnc01
Private oEnc02
Private oGetDados
Private oGetDadosFD

//Variaveis da Selecao
Private oLbxSel1,oLbxSel2,oLbxSel3
Private aMarca := {}
Private aGener := {}
Private aEspec := {}

nOpcaX     := 0

Aadd(aPages,"HEADER 1")
nControl++

If cParPrg $ "12" // Simulacao ou Proposta/Pedido
	Aadd(aPages,"HEADER 2")
	nControl++
	Aadd(aPages,"HEADER 3")
	nControl++
	Aadd(aPages,"HEADER 4")
	nControl++
Endif

If cParPrg == "1" // Simulacao
	Aadd(aPages,"HEADER 5")
	nControl++
Endif

nOpca    := 0
cMensGrv := OemToAnsi(STR0092)

SETAPILHA()
DEFINE MSDIALOG oDlgFold TITLE cCadastro FROM  4.5,0 To 36,80 OF oMainWnd

SetEnch("")

if cParPrg # "3"
	oFolderV := TFolder():New(1,0,aTitles,aPages,odlgfold,,,,.F.,.F.,318,227,)
	oFolderV:nOption := 1
	oFolderV:bSetOption  := {|x| FS_MUDAABA("V",x,nOpc)}
	oFolderV:bChange     := {|x| nAbaAnt := x }
	If cParPrg == "1"     //Simulacao
		FG_INIFOLDER("oFolderV",5)
	ElseIf cParPrg == "2" //Proposta/Pedido
		FG_INIFOLDER("oFolderV",4)
	Endif
	
	If cParPrg $ "12" // Simulacao ou Proposta/Pedido
		Aadd(aPages2,"HEADER 1")
		nControl++
		Aadd(aPages2,"HEADER 2")
		nControl++
	Endif
	
	oFolder2 := TFolder():New(1,0,aTitles2,aPages2,oFolderV:aDialogs[3],,,,.F.,.F.,317,227,)
	If cParPrg == "1"     //Simulacao
		FG_INIFOLDER("oFolder2",2)
	ElseIf cParPrg == "2" //Proposta/Pedido
		FG_INIFOLDER("oFolder2",2)
	Endif
	
	Aadd(aPages3,"HEADER 1")
	nControl++
	Aadd(aPages3,"HEADER 2")
	nControl++
	
	/*
	if cTipSai == "0"     // Venda
	if  cParPrg $ "12" // Simulacao ou Proposta/Pedido
	@ 0,.1 SCROLLBOX oScroll VERTICAL SIZE 251,315 OF oFolderV:aDialogs[2] BORDER PIXEL
	Endif
	Else
	aTipFat  := {OemToAnsi(STR0037),OemToAnsi(STR0038)}
	@ 0,.1 SCROLLBOX oScroll VERTICAL SIZE 251,315 OF oFolderV:aDialogs[1] BORDER PIXEL
	Endif
	*/
	
	oFolder3 := TFolder():New(0,0,aTitles3,aPages3,oFolderV:aDialogs[2],,,,.F.,.F.,316,215,)
	FG_INIFOLDER("oFolder3",2)
	
Endif

if nOpc # 3
	oFolderV:noption := 2
	lMntTel := .f.
Endif

if cParPrg # "3" .and. cTipFat == "2"
	nAbaAnt := 2
	oFolderV:nOption := 2
Endif

//	if cParPrg $ "12"    // Simulacao ou Proposta/Pedido
//		if cParPrg == "1" // Simulacao
//			oFolderV:aDialogs[5]:oFont := oDlgFold:oFont
//		Endif
//	Endif

if cParPrg $ "12" // Simulacao ou Proposta/Pedido
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tela 1 - Selecao do Veiculo              	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTela := {}
	aGets := {}
	aStruVV1 := {}
	// N=Normal ; B=Reservado ; R=Remessa ; C=Consignado
	aAdd(aStruVV1, { .f.,"N",.f.," "," "," "," "," ",0,"","","",0,"" } )
	
	if cTipFat == "0"  //Novo
		VE4->(dbSetOrder(1))
		VE4->(dbSeek(xFilial("VE4")))
	Endif
	
	aadd(aMarca ,"")
	aadd(aGener ,"")
	aadd(aEspec ,"")
	
	dbSelectArea("VE1")
	dbSetOrder(1)
	dbSeek(xFilial("VE1"))
	While !Eof() .and. xFilial("VE1") == VE1->VE1_FILIAL
		aadd(aMarca,VE1->VE1_CODMAR)
		dbSkip()
	Enddo
	if Len(aMarca) == 0
		aMarca := {""}
	Endif
	
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+aMarca[1])
	While !Eof() .and. xFilial("VVR") == VVR->VVR_FILIAL .and. VVR->VVR_CODMAR == aMarca[1]
		if aScan(aGener,VVR->VVR_DESCRI) = 0
			aadd(aGener,VVR->VVR_DESCRI)
		Endif
		dbSkip()
	Enddo
	if Len(aGener) == 0
		aGener := {{""}}
	Endif
	
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+aMarca[1]+aGener[1])
	dbSelectArea("VV2")
	dbSetOrder(3)
	dbSeek(xFilial("VV2")+aMarca[1]+VVR->VVR_GRUMOD)
	While !Eof() .and. xFilial("VV2") == VV2->VV2_FILIAL .and. VVR->VVR_CODMAR == aMarca[1] .and. VV2->VV2_GRUMOD == VVR->VVR_GRUMOD
		if aScan(aEspec,VV2->VV2_DESMOD) = 0
			aadd(aEspec,VV2->VV2_DESMOD)
		Endif
		dbSkip()
	Enddo
	if Len(aEspec) == 0
		aEspec := {""}
	Endif
	
	@  000, 001 SAY STR0063 SIZE 80,8 OF oFolderV:aDialogs[1] PIXEL COLOR CLR_BLUE  //Marca
	@  007, 001 MSCOMBOBOX cbxCodMar VAR cCodMar SIZE 98,50 FONT oFnt4 COLOR CLR_BLACK ITEMS aMarca OF oFolderV:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,1) PIXEL
	
	@  000, 108 SAY STR0188 SIZE 80,8 OF oFolderV:aDialogs[1] PIXEL COLOR CLR_BLUE   //Modelo Generico
	@  007, 108 MSCOMBOBOX cbxGruMod VAR cGruMod SIZE 98,50 FONT oFnt4 COLOR CLR_BLACK ITEMS aGener OF oFolderV:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,2) PIXEL
	
	@  000, 217 SAY STR0189 SIZE 80,8 OF oFolderV:aDialogs[1] PIXEL COLOR CLR_BLUE  //Modelo especifico
	@  007, 217 MSCOMBOBOX cbxModVei VAR cModVei SIZE 98,50 FONT oFnt4 COLOR CLR_BLACK ITEMS aEspec OF oFolderV:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,3) PIXEL
	
	cCodMar := ""
	cGruMod := ""
	cModVei := ""
	
	FS_FILTROVV(.f.)
	
	lVar0 := .f.
	lVar1 := .f.
	lVar2 := .f.
	
	/*
	@ 014,001 CHECKBOX oChk0 VAR lVar0 PROMPT OemToAnsi("Todos") SIZE 95, 12 OF oFolderV:aDialogs[1] ON CLICK(oChk0:lVisible := .f.,FS_CLICK(lVar0,0),oChk0:lVisible := .t.) PIXEL
	@ 014,104 CHECKBOX oChk1 VAR lVar1 PROMPT OemToAnsi("Todos") SIZE 95, 12 OF oFolderV:aDialogs[1] ON CLICK(oChk1:lVisible := .f.,FS_CLICK(lVar1,1),oChk1:lVisible := .t.) PIXEL
	@ 014,207 CHECKBOX oChk2 VAR lVar2 PROMPT OemToAnsi("Todos") SIZE 95, 12 OF oFolderV:aDialogs[1] ON CLICK(oChk2:lVisible := .f.,FS_CLICK(lVar2,2),oChk2:lVisible := .t.) PIXEL
	*/
	
	nLin := 20
	
	if cEstoque == "S"
		
		@ nLin,1 LISTBOX oLbox FIELDS HEADER;
		OemToAnsi(""),;        //Indicador de Relacionamento
		OemToAnsi("R"),;       //Indicador p/ veiculos reservados
		OemToAnsi(STR0325),;    //FOTO - Indica se o veiculo tem foto cadastrada
		OemToAnsi(STR0326),;   //Dias em estoque
		OemToAnsi(STR0088),;   //Chassi
		OemToAnsi(STR0064),;   //Modelo
		OemtoAnsi(STR0063),;   //Marca
		OemtoAnsi(STR0065),;   //Cor
		OemToAnsi(STR0141+allTrim(cMoedCor)),;  //Preco
		OemToAnsi(STR0139),;   //Estado (Novo/Usado)
		OemToAnsi(STR0140),;   //Ano Fabricacao
		OemToAnsi(STR0293),;   //Ano Modelo
		OemToAnsi(STR0138),;    //Kilometragem
		OemToAnsi(STR0327);    //Em Poder de
		COLSIZES 5,5,5,15,65,72,19,50,45,22,20,20,40,50;
		SIZE 313,177 OF oFolderV:aDialogs[1] PIXEL ON DBLCLICK (nPos:=oLbox:nAt,FS_MarcVei(),cTipFat:=if(aStruVV1[nPos,10]==STR0316,"0","1"),oLbox:Refresh(),oLbox:nAt:=nPos)   //Novo
		
		if len(aStruVV1) == 0
			aAdd(aStruVV1, { .f.,"N",.f.," "," "," "," "," ",0,"","","",0,"" } )
		Endif
		
		oLbox:SetArray(aStruVV1)
		oLbox:bLine := { || { if(aStruVV1[oLbox:nAt,01] == .f.,oNo,oTik),;
		iif(aStruVV1[oLbox:nAt,02] == "N",oNo,fs_corbrowse(oLbox:nAt)),;
		iif(aStruVV1[oLbox:nAt,03] == .f.,oNada,oFoto),;
		aStruVV1[oLbox:nAt,04],;
		aStruVV1[oLbox:nAt,05],;
		aStruVV1[oLbox:nAt,06],;
		aStruVV1[oLbox:nAt,07],;
		aStruVV1[oLbox:nAt,08],;
		FG_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"9,999,999.99")),;
		aStruVV1[oLbox:nAt,10],;
		aStruVV1[oLbox:nAt,11],;
		aStruVV1[oLbox:nAt,12],;
		aStruVV1[oLbox:nAt,13],;
		aStruVV1[oLbox:nAt,14]} }
		
		nLin += 178
		@ nLin, 001 TO nLin+15,315 LABEL OemtoAnsi(STR0304) OF oFolderV:aDialogs[1] PIXEL //Legenda
		
		@ nLin+6,010 BITMAP oxNormal RESOURCE "LBNO" OF oFolderV:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL
		@ nLin+6,020 SAY STR0328 OF oFolderV:aDialogs[1] SIZE 32,08 PIXEL COLOR CLR_BLACK //Normal
		@ nLin+6,090 BITMAP oxReservado RESOURCE "BR_AMARELO" OF oFolderV:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL
		@ nLin+6,100 SAY STR0329 OF oFolderV:aDialogs[1] SIZE 32,08 PIXEL COLOR CLR_BLACK  //Reservado
		@ nLin+6,170 BITMAP oxVerde RESOURCE "BR_VERMELHO" OF oFolderV:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL
		@ nLin+6,180 SAY STR0330 OF oFolderV:aDialogs[1] SIZE 32,08 PIXEL  //Remessa
		@ nLin+6,250 BITMAP oxAzul RESOURCE "BR_AZUL" OF oFolderV:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL
		@ nLin+6,260 SAY STR0331 OF oFolderV:aDialogs[1] SIZE 42,08 PIXEL COLOR CLR_BLACK  //Consignado
	Endif
	
	aSvATela[1] := aClone(aTela)
	aSvAGets[1] := aClone(aGets)
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela 2 - Venda / Simulacao        	                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}

If cParPrg $ "12" // Simulacao ou Proposta/Pedido
	aSvATela[2] := aClone(aTela)
	aSvAGets[2] := aClone(aGets)
Else
	aSvATela[1] := aClone(aTela)
	aSvAGets[1] := aClone(aGets)
	lTelSim := .f.
Endif

nAliIssFd  := 0
nAliIss    := GETMV("MV_TXISS")  / 100
nAliPis    := GETMV("MV_TXPIS")  / 100
nAliCof    := GETMV("MV_TXCOFIN")/ 100
lDigVda    := .t.
nOpcaX     := 0

Lin := 4
if cParPrg == "3"
	Lin := 13
Endif

lValGeral := nOpc == 3 .or. nOpc == 4

VE1->(dbSetOrder(1))
VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR))
cDesMar := VE1->VE1_DESMAR
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
cDesMod := VV2->VV2_DESMOD
VVC->(dbSetOrder(1))
VVC->(dbSeek(xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI))
cDesCor := Subs(VVC->VVC_DESCRI,1,19)

/*
If cTipFat == "2" .and. cParPrg # "3"
FS_TELFATDIR(nOpc)    //Entrada e Saida para Faturamento Direto
Else
FS_MONTATELA(nOpc)   //Monta a Tela dos Dados da Simulacao/Proposta
Endif
*/

aTela := {}
aGets := {}
dbSelectArea("VV0")
Zero()
oGetMGet1:= MsMGet():New("VV0",0,nOpcE,,,,aPriEnc,{000,000,203,315},,2,,,,oFolder3:aDialogs[1],,.T.,.F.,"aSvTela[1]")
oGetMGet1:oBox:bGotFocus   := {|| AL_Entra(1,"VV0")}
//oGetMGet1:oBox:bChange     := {|| Fs_ValInte() }
oGetMGet1:oBox:bLostFocus  := {|| AL_Sai(1)}
aSvTela[1] := aClone(aTela)
aSvGets[1] := aClone(aGets)

aTela := {}
aGets := {}
dbSelectArea("VVA")
Zero()
oGetMGet2:= MsMGet():New("VVA",0,nOpcE,,,,aSegEnc,{000,000,203,315},,2,,,,oFolder3:aDialogs[2],,.T.,.F.,"aSvTela[2]")
oGetMGet2:oBox:bGotFocus   := {|| AL_Entra(1,"VVA")}
//oGetMGet2:oBox:bChange     := {|| Fs_ValInte() }
oGetMGet2:oBox:bLostFocus  := {|| AL_Sai(1)}
aSvTela[2] := aClone(aTela)
aSvGets[2] := aClone(aGets)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela 3 - Enchoice 2 - Equipamentos Instalados - Acessorios  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  cParPrg $ "12" // Simulacao - Proposta/Pedido
	FS_EQPINS(nOpc)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela 4 - Condicao de Pagto                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}

If cParPrg $ "12" // Simulacao ou Proposta/Pedido
	FG_TELACOND(oFolderV:aDialogs[4],cTipOpe,nOpc)
	
	DEFINE BUTTONBAR oBar1 SIZE 25,25 3D TOP OF oFolderV:aDialogs[4]
	DEFINE BUTTON oBt1 RESOURCE "PRECO"     OF oBar1 ACTION  FS_SIMULAFIN() TOOLTIP STR0332
	DEFINE BUTTON oBt2 RESOURCE "PESQUISA"  OF oBar1 ACTION  FS_FICHA()     TOOLTIP STR0333
	DEFINE BUTTON oBt3 RESOURCE "AUTOM"     OF oBar1 ACTION  FS_FICHAVEI(cOutMoed,3,"V",cTipSai) TOOLTIP STR0319 //Avaliacao de Resultado
	
	aSvATela[4] := aClone(aTela)
	aSvAGets[4] := aClone(aGets)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela 5 -  Avaliacao do Resultado do Veiculo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cParPrg # "3" //Faturamento
	
	@ 26,004 SAY OemToAnsi(STR0078)  OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLUE    //Banco
	@ 26,044 MSGET oCodBco VAR M->VV0_CODBCO PICTURE "@!" F3 "A61" VALID VLD(16) SIZE 40,4 OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLACK when  lValGeral
	@ 26,094 SAY OemToAnsi(STR0087)  OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLUE    //Agencia
	@ 26,134 MSGET oCodAge VAR M->VV0_CODAGE PICTURE "@!" SIZE 40,4 OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLACK when lValGeral
	
	if cParPrg == "2"  //Proposta
		aAutFat  := {OemToAnsi(STR0031),OemToAnsi(STR0030)}
		@ 26,204 SAY OemToAnsi(STR0190) OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLUE
		@ 26,263 MSCOMBOBOX oAutFat VAR M->VV0_AUTFAT SIZE 30,40 COLOR CLR_BLUE;
		ITEMS aAutFat OF oFolderV:aDialogs[4] PIXEL When (lValGeral .and. cParPrg == "2")
		
		//Reserva
		Private oCbReserv
		Private aCbReserv := {OemToAnsi(STR0031),OemToAnsi(STR0030)}
		@ 40,204 SAY  OemToAnsi(STR0258)  OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLUE
		@ 40,263 MSCOMBOBOX oCbReserv VAR M->VV0_RESERV SIZE 30,40 COLOR CLR_BLACK ITEMS aCbReserv OF oFolderV:aDialogs[4] PIXEL when M->VV0_AUTFAT == "0"
		
		@ 55,204 SAY  OemToAnsi(STR0144) OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLACK //Data
		@ 65,204 MSGET oDatVal VAR M->VV0_DATVAL PICTURE "@D" VALID M->VV0_DATVAL >= dDataBase SIZE 55,4 OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLACK when (M->VV0_RESERV $ "1/3" .and. M->VV0_AUTFAT == "0")
	Endif
	
	@ 40,004 SAY OemToAnsi(STR0158)  OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLUE    //Agente Financeiro
	@ 40,044 MSGET oAgeFin VAR M->VV0_AGEFIN PICTURE "@!" F3 "A62" VALID VLD(23) SIZE 40,4 OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLACK when lValGeral
	@ 40,094 SAY OemToAnsi(STR0159)  OF oFolderV:aDialogs[4] PIXEL COLOR CLR_BLUE    //Transporte p/ Conta do Proprietario
	@ 40,134 MSCOMBOBOX oTransp VAR cTransp VALID VLD(24) SIZE 60,50 COLOR CLR_BLACK;
	ITEMS aTransp OF oFolderV:aDialogs[4] PIXEL when (lValGeral  .and. cParPrg == "2")
	
Endif

cOpeMov  := M->VV0_OPEMOV

ACTIVATE MSDIALOG oDlgFold CENTER ON INIT (EnchoiceBar(oDlgFold, {|| Fs_FecVM010(),if(lOk,oDlgFold:End(),.f.)},{||nOpca := 2,lTelVdaSim := .f.,oDlgFold:End()},,aNewBot),AL_Inicia())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no indice da IndRegua                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
RetIndex()
dbSetOrder(1)
Eval(bFiltraBrw)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | Fs_FecVM010   ³ Autor ³  Andre           ³ Data   12/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o fechamento da proposta                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fs_FecVM010()

lOk := .t.

if FS_TOKVM010()
	lTelVdaSim := .f.
	nOpca      := 1
	Processa({|| if(FS_FINVM010(nOpc),lOk := .t., lOk := .f.) })
Else
	lOk   := .f.
	nOpca := 2
Endif

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_MONTATELA   ³ Autor ³  Manoel          ³ Data   27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Tela de Venda de Veiculos Normal de Veiculos          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MONTATELA(nOpc)

Local  oScroll

if lMntTel
	Return
Endif

If oScroll # NIL
	DeleteObject(oScroll)
EndIf

if cTipSai == "0" // Venda
	if cParPrg $ "12" // Simulacao ou Proposta/Pedido
		@ 2,.1 SCROLLBOX oScroll VERTICAL SIZE 251,315 OF oFolderV:aDialogs[2] BORDER PIXEL
	Endif
Else
	aTipFat  := {OemToAnsi(STR0037),OemToAnsi(STR0038)}
	@ 2,.1 SCROLLBOX oScroll VERTICAL SIZE 251,315 OF oFolderV:aDialogs[1] BORDER PIXEL
Endif

lValGeral := nOpc == 3 .or. nOpc == 4

if cTipSai == "0" // Venda
	
	if cParPrg $ "12" // Simulacao ou Proposta/Pedido
		// DADOS DA NOTA FISCAL
		@ Lin,004 SAY OemToAnsi(STR0051)  OF oScroll PIXEL COLOR CLR_BLUE //Cliente
		@ Lin,044 MSGET oCodCli VAR M->VV0_CODCLI PICTURE "@9" F3 "VSC" VALID VLD(7) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		@ Lin,144 SAY OemToAnsi(STR0094)  OF oScroll PIXEL COLOR CLR_BLUE //Loja
		@ Lin,184 MSGET oLojaCli VAR M->VV0_LOJA PICTURE "@9" VALID VLD(18) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK
		@ Lin,224 SAY oNomCli VAR cNomCli OF oScroll PIXEL SIZE 84,6 COLOR CLR_BLUE FONT oFnt4
		
		Lin := lin + 11
		
		@ Lin,004 SAY OemToAnsi(STR0047) OF oScroll PIXEL COLOR CLR_BLUE //TES
		@ Lin,044 MSGET oCodtes VAR M->VVA_CODTES PICTURE "@!S3" F3 "SF4" VALID VLD(17) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
		@ Lin,144 SAY OemToAnsi(STR0057)  OF oScroll PIXEL COLOR CLR_BLUE //Vendedor
		@ Lin,184 MSGET oCodVen VAR M->VV0_CODVEN PICTURE "@E9" F3 "SA3" VALID VLD(15) SIZE 40,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
		@ Lin,224 SAY cNomVen OF oScroll PIXEL SIZE 84,6 COLOR CLR_BLUE FONT oFnt4
		Lin := lin + 15
		
		if cTipSai == "0" // Venda
			if cEstoque == "S"
				@  27, 002 TO 135,312 LABEL "" OF oScroll PIXEL
			Else
				@  26, 002 TO 145,312 LABEL "" OF oScroll PIXEL
			Endif
		Endif
		
		// DADOS DO VEICULO
		@ Lin,004 SAY OemToAnsi(STR0088)  OF oScroll PIXEL COLOR CLR_BLUE  //Chassi
		@ Lin,044 MSGET oChassi VAR M->VVA_CHASSI PICTURE "@!S25" F3 "V12" VALID VLD(1) SIZE 83,4 OF oScroll PIXEL COLOR CLR_BLACK when  (lValGeral .and. cEstoque == "S")
		
		@ Lin,144 SAY OemToAnsi(STR0062) OF oScroll PIXEL COLOR CLR_BLACK  //Chassi Interno
		@ Lin,184 MSGET M->VVA_CHAINT PICTURE "@!S15" SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when .f.
		Lin := lin + 11
		@ Lin,004 SAY OemToAnsi(STR0063)  OF oScroll PIXEL COLOR CLR_BLACK //Marca
		@ Lin,044 MSGET oMarca VAR M->VV1_CODMAR PICTURE "@!" F3 "VE1" VALID VLD(2) SIZE 40,4 OF oScroll PIXEL COLOR CLR_BLACK when (cEstoque == "N"  .and.  lValGeral .and. cTipSai # "4") //Devolucao
		@ Lin,084 SAY cDesMar OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
		@ Lin,144 SAY OemToAnsi(STR0064) OF oScroll PIXEL COLOR CLR_BLACK //Modelo
		@ Lin,184 MSGET oModelo VAR M->VV1_MODVEI PICTURE "@!" F3 "MCV" VALID VLD(3) SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when (cEstoque == "N" .and.  lValGeral .and. cTipSai # "4") //Devolucao
		@ Lin,240 SAY oDesMod VAR cDesMod SIZE 85,6 OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
		Lin := lin + 11
		
		if nOpc <> 3
			@ Lin,245 SAY  OemToAnsi(STR0259) OF oScroll PIXEL FONT oFnt4 COLOR CLR_BLACK //Numero da Transacao
		Endif
		
		@ Lin,004 SAY  OemToAnsi(STR0065)  OF oScroll PIXEL COLOR CLR_BLACK //Cor
		@ Lin,044 MSGET oCor VAR M->VV1_CORVEI PICTURE "@!" F3 "VVC" VALID VLD(4) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when ((cEstoque == "N" .and. lValGeral) .or. (nOpc == 4 .and. cTipSai == "1" .and. cEstoque == "N")) //Simulacao
		@ Lin,084 SAY oDesCor VAR Subs(cDesCor,1,16) SIZE 55,6 OF oScroll PIXEL COLOR CLR_BLUE  FONT oFnt4
		If cEstoque == "N" //Nao Estoque
			M->VV0_MODVDA := cTipFat
			@ Lin,144 SAY OemToAnsi(STR0066) OF oScroll PIXEL COLOR CLR_BLACK //Vlr Custo
			@ Lin,184 MSGET oValCus VAR M->VVA_VCAVEI PICTURE "@E 999,999,999.99"  VALID VLD(29) SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when  lWhenCus
			Lin := Lin + 11
			@ Lin,004 SAY OemToAnsi(STR0072) OF oScroll PIXEL COLOR CLR_BLACK //Acr Vlr Cor
			@ Lin,044 MSGET oValCor VAR nValCor PICTURE "@E 999,999,999.99" Valid VLD(5) SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when  str(nOpc,1) $ "34"
			@ Lin,144 SAY OemToAnsi(STR0142) OF oScroll PIXEL COLOR CLR_BLACK
			@ Lin,184 MSGET oValSCor VAR nValSCor PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when  .f.
			Lin := lin + 11
		Else
			@ Lin,144 SAY OemToAnsi(STR0066) OF oScroll PIXEL COLOR CLR_BLACK //Vlr Custo
			@ Lin,184 MSGET oValCus VAR M->VVA_VCAVEI PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lWhenCus
			Lin := lin + 11
		Endif
		
		if nOpc <> 3
			@ Lin,245 SAY  VV0->VV0_NUMTRA OF oScroll PIXEL FONT oFnt4 COLOR CLR_BLACK //Numero da Transacao
		Endif
		
		@ Lin,004 SAY  OemToAnsi(STR0116) OF oScroll PIXEL COLOR CLR_BLACK //Acessorios
		@ Lin,044 MSGET oAcesso VAR M->VVA_ACESSO PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when .f.
		@ Lin,144 SAY  OemToAnsi(STR0143) OF oScroll PIXEL COLOR CLR_BLACK
		@ Lin,184 MSGET oCusAce VAR nCusAce PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when .f.
		Lin := lin + 11
		@ Lin,004 SAY  OemToAnsi(STR0068) OF oScroll PIXEL COLOR CLR_BLACK //Red Custo
		@ Lin,044 MSGET oRedCus VAR M->VVA_REDCUS PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
		@ Lin,184 MSGET oDatRcu VAR M->VVA_DATRCU PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		Lin := lin + 11
		@ Lin,004 SAY OemToAnsi(STR0074) OF oScroll PIXEL COLOR CLR_BLACK //Rec.Tecnica
		@ Lin,044 MSGET oRecTec VAR M->VVA_RECTEC PICTURE "@E 999,999,999.99" VALID VLD(6) SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral .or. (nOpc == 4 .and. cTipSai == "1" )//Simulacao
		@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
		@ Lin,184 MSGET oDatRtc VAR M->VVA_DATRTC PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		Lin := lin + 11
		@ Lin,004 SAY OemToAnsi(STR0075) OF oScroll PIXEL COLOR CLR_BLACK //Bonus Fabrica
		@ Lin,044 MSGET oBonFab VAR M->VVA_BONFAB PICTURE "@E 999,999,999.99" VALID VLD(28) SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral .and. cTipFat # "1" //Usados
		@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
		@ Lin,184 MSGET oDatBfb VAR M->VVA_DATBFB PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		Lin := lin + 11
		@ Lin,004 SAY OemToAnsi(STR0079) OF oScroll PIXEL  COLOR CLR_BLACK //Desp Cliente
		@ Lin,044 MSGET oDesCli VAR M->VVA_DESCLI PICTURE "@E 999,999,999.99"  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK When lValGeral
		@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
		@ Lin,184 MSGET oDatDCL VAR M->VVA_DATDCL PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		@ Lin,243 BUTTON oOutDesp PROMPT OemToAnsi(STR0334) OF oScroll SIZE 43,11 PIXEL  ACTION FS_LISTDESP()  //Outras Despesas/Receitas
		
		Lin := lin + 11
		@ Lin,004 SAY OemToAnsi(STR0145) OF oScroll PIXEL  COLOR CLR_BLACK
		@ Lin,044 MSGET oValFre VAR M->VVA_VALFRE PICTURE "@E 999,999,999.99"  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK When lValGeral
		@ Lin,144 SAY  OemToAnsi(STR0146) OF oScroll PIXEL COLOR CLR_BLACK
		@ Lin,184 MSGET oValRev VAR M->VVA_VALREV PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		
		If cParPrg == "2"
			@ Lin,243 BUTTON oObserv PROMPT OemToAnsi(STR0077)  OF oScroll SIZE 43,11 PIXEL  ACTION FS_ObsVei(nOpc)  //Observacoes
		Endif
		Lin := lin + 17
		@ Lin,004 SAY OemToAnsi(STR0147) OF oScroll PIXEL COLOR CLR_BLUE //Vlr Movto
		@ Lin,044 MSGET oValVei VAR M->VVA_VALVDA PICTURE "@E 999,999,999.99" VALID VLD(13) SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
		@ Lin,144 SAY OemToAnsi(STR0084) OF oScroll PIXEL COLOR CLR_BLACK //Vlr Desconto
		@ Lin,184 MSGET oValDes VAR M->VVA_VALDES PICTURE "@E 999,999,999.99" VALID VLD(13) SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
		
		Lin := Lin + 11
		@ Lin,004 SAY OemToAnsi(STR0148)  OF oScroll PIXEL COLOR CLR_BLUE
		@ Lin,044 MSGET oDesAce VAR M->VV0_DESACE PICTURE "@E 999,999,999.99" VALID VLD(27) SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when !cTipSai $ "2" .and.  lValGeral
		@ Lin,144 SAY OemToAnsi(STR0085)  OF oScroll PIXEL COLOR CLR_BLACK //Base do ICMS
		@ Lin,184 MSGET oVbaIcm VAR M->VVA_VBAICM PICTURE "@E 999,999,999.99"   SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when .f.
		
		Lin := lin + 11
		@ Lin,004 SAY OemToAnsi(STR0076)  OF oScroll PIXEL COLOR CLR_BLUE //Aliquota ICMS
		@ Lin,044 MSGET oAliIcm VAR M->VVA_ALIICM PICTURE "@E 999.99" VALID VLD(10)  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral .and. cTipSai # "4" //Devolucao
		@ Lin,144 SAY OemToAnsi(STR0086)  OF oScroll PIXEL COLOR CLR_BLACK //Base do ICMS
		@ Lin,184 MSGET oValIcm VAR M->VVA_ICMVEN PICTURE "@E 999,999,999.99"   SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when .f.
		
		Lin := lin + 11
		if cParPrg == "2"  //Proposta/Pedido
			@ Lin,004 SAY OemToAnsi(STR0053)  OF oScroll PIXEL COLOR CLR_BLUE //Categoria da Venda
			@ Lin,044 MSCOMBOBOX oCatVen VAR M->VV0_CATVEN SIZE 65,50 COLOR CLR_BLACK;
			ITEMS aCatVen OF oScroll PIXEL when lValGeral
			@ Lin,144 SAY OemToAnsi(STR0055)  OF oScroll PIXEL COLOR CLR_BLUE //Tipo de Venda
			@ Lin,184 MSGET oTipVen VAR M->VV0_TIPVEN PICTURE "@!" F3 "VV3" VALID VLD(14) SIZE 23,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
			@ Lin,204 SAY oDesTvd VAR cDesTvd SIZE 95,6 OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
			Lin := lin + 11
			@ Lin,004 SAY OemToAnsi(STR0056) OF oScroll PIXEL COLOR CLR_BLACK //Alienado a
			@ Lin,044 MSGET oCliAli VAR M->VV0_CLIALI PICTURE "@E9" F3 "VSC" VALID VLD(9)  SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
			@ Lin,084 MSGET oLojAli VAR M->VV0_LOJALI PICTURE "@9"  VALID VLD(22) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
			@ Lin,102 SAY cNomAli OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
			Lin := lin + 11
			@ Lin,004 SAY OemToAnsi(STR0052)  OF oScroll PIXEL COLOR CLR_BLACK //Avalista
			@ Lin,044 MSGET oCodAva VAR M->VV0_CODAVA PICTURE "@E9" F3 "VSC" VALID VLD(8) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
			@ Lin,084 MSGET oLojaAva VAR M->VV0_LOJAAV PICTURE "@9" VALID VLD(19) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
			@ Lin,102 SAY cNomAva OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
			Lin := lin - 05
		Endif
		if cParPrg == "1"
			Lin := Lin + 11
		Endif
		
		@ Lin,144 SAY OemToAnsi(STR0149)  OF oScroll PIXEL COLOR CLR_BLACK FONT oFnt5
		@ Lin,184 SAY oValMov VAR cMoedCor+" "+tran(M->VVA_VALMOV,"@E 999,999.99")  OF oScroll PIXEL COLOR CLR_HRED FONT oFnt5
		
		If VV0->VV0_TIPFAT == "2"
			nTotEnt := M->VVA_VALCVD
		Else
			nTotEnt := M->VVA_VALMOV
		Endif
		
		@ 001, 002 TO 208,312 LABEL "" OF oScroll PIXEL
		
	Elseif (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
		
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI))
		cNomCli := SA1->A1_NOME
		cEndCli := SA1->A1_END
		cCGCCPF := SA1->A1_CGC
		if SA1->A1_TIPO == "F"
			cPicture := "@R 999.999.999.99"
		Else
			cPicture := "@R 99.999.999/9999-99"
		Endif
		
		SE4->(dbSetOrder(1))
		SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
		cDesFpg := alltrim(SE4->E4_DESCRI)
		SA3->(dbSetOrder(1))
		SA3->(dbSeek(xFilial("SA3")+M->VV0_CODVEN))
		cNomVen := SA3->A3_NOME
		VV1->(dbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1")+M->VVA_CHAINT))
		VE1->(dbSetOrder(1))
		VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
		cDesMar := VE1->VE1_DESMAR
		VVC->(dbSetOrder(1))
		VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
		cDesCor := VVC->VVC_DESCRI
		
		M->VV0_DATMOV := dDataBase
		if VV0->VV0_TIPFAT == "0"
			cDesTpV := OemToAnsi(STR0178)
		Elseif VV0->VV0_TIPFAT == "1"
			cDesTpV := OemToAnsi(STR0179)
		Elseif VV0->VV0_TIPFAT == "2"
			cDesTpV := OemToAnsi(STR0180)
		Endif
		
		@ Lin,004 SAY OemToAnsi(STR0150)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //Pedido
		@ Lin,068 SAY M->VV0_NUMPED+" / "+M->VV0_NUMTRA OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		@ Lin,160 SAY OemToAnsi(STR0151)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //Data
		@ Lin,224 SAY M->VV0_DATMOV OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		Lin += 9
		@ Lin,004 SAY STR0191 OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLACK
		Lin += 6
		@ Lin,005 TO lin+2,310 LABEL "" OF oDlgFold PIXEL  //Linha Separadora
		Lin += 6
		@ Lin,004 SAY OemToAnsi(STR0051)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //Cliente
		@ Lin,068 SAY oNomCli VAR cNomCli OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		@ Lin,198 SAY OemToAnsi(STR0094)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //Loja
		@ Lin,224 SAY M->VV0_LOJA OF oDlgFold PIXEL FONT oFnt4  COLOR CLR_RED
		Lin += 9
		@ Lin,004 SAY OemToAnsi(STR0192)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //Endereco
		@ Lin,068 SAY cEndCli OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLACK
		@ Lin,184 SAY OemToAnsi(STR0193)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //CNPJ/CPF
		@ Lin,224 SAY Transform(cCGCCPF,cPicture) SIZE 100,08 OF oDlgFold PIXEL FONT oFnt3 COLOR CLR_BLACK
		Lin += 9
		@ Lin,004 SAY STR0194 OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLACK
		Lin += 6
		@ Lin,005 TO lin+2,310 LABEL "" OF oDlgFold PIXEL  //Linha Separadora
		Lin += 6
		@ Lin,004 SAY OemToAnsi(STR0088)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE  //Chassi
		@ Lin,068 Say M->VVA_CHASSI OF oDlgFold PIXEL  FONT oFnt4  COLOR CLR_RED
		@ Lin,173 SAY OemToAnsi(STR0057)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE  //Vendedor
		@ Lin,210 SAY cNomVen OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		Lin := lin + 9
		@ Lin,004 SAY OemToAnsi(STR0063)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE  //Marca
		@ Lin,068 SAY cDesMar OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		if !Empty(VV0->VV0_CLIALI)
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CLIALI))
			cNomAli  := SA1->A1_NOME
			@ Lin,173 SAY OemToAnsi(STR0335)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE  //Alienado
			@ Lin,210 SAY cNomAli OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		Endif
		Lin := lin + 9
		@ Lin,004 SAY OemToAnsi(STR0064) OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE   //Modelo
		@ Lin,068 SAY VV1->VV1_MODVEI OF oDlgFold PIXEL  FONT oFnt4  COLOR CLR_RED
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		cDesMod := VV2->VV2_DESMOD
		@ Lin,110 SAY oDesMod VAR cDesMod SIZE 85,6 OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
		Lin := lin + 9
		@ Lin,004 SAY  OemToAnsi(STR0065)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE //Cor
		@ Lin,068 SAY oDesCor VAR cDesCor OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		Lin += 9
		@ Lin,004 SAY STR0195 OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLACK
		Lin += 6
		@ Lin,005 TO lin+2,310 LABEL "" OF oDlgFold PIXEL  //Linha Separadora
		Lin += 6
		
		If VV0->VV0_TIPFAT == "2"
			nTotEnt := M->VVA_VALCVD
		Else
			nTotEnt := M->VVA_VALMOV
		Endif
		
		//Forma de Pagamento
		cTipPag := M->VV0_FORPAG
		
		nc          := 1
		nLinhas     := 99
		aHeader     := aClone(aHeaderC)
		aCols       := aClone(aColsC)
		oGetCondicao:= MsGetDados():New(Lin,004,Lin+62,310,2,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,99,"AllwaysTrue()",,,,oDlgFold)
		oGetCondicao:oBrowse:default()
		
		Lin += 65
		@ Lin,200 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0144),OemToAnsi(STR0155);
		COLSIZES 40,50;
		SIZE 110,061 OF oDlgFold PIXEL
		
		oLbParc:SetArray(aIteParc)
		oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
		Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}
		
		Lin += 5
		@ Lin,004 SAY OemToAnsi(STR0154) OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE
		@ Lin,070 SAY oValMov VAR Trans(M->VVA_VALMOV,"@E 99,999,999.99") SIZE 60,08 OF oDlgFold PIXEL FONT oFnt3 COLOR CLR_BLACK
		Lin += 9
		@ Lin,004 SAY OemToAnsi(STR0054)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLUE
		@ Lin,078 SAY cDesFpg OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_RED
		Lin += 12
		if !Empty(VV0->VV0_NUMNFI)
			@ Lin,004 SAY OemToAnsi(STR0196)        OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLACK //Serie
			@ Lin,048 SAY FGX_UFSNF(VV0->VV0_SERNFI) OF oDlgFold PIXEL FONT oFnt3 COLOR CLR_RED
			Lin += 9
			@ Lin,004 SAY OemToAnsi(STR0197)  OF oDlgFold PIXEL FONT oFnt4 COLOR CLR_BLACK //Nota Fiscal
			@ Lin,048 SAY VV0->VV0_NUMNFI OF oDlgFold PIXEL FONT oFnt3  COLOR CLR_RED
		Else
			Lin += 9
		Endif
		
		Lin += 20
		@ Lin,004 SAY cDesTpV OF oDlg PIXEL FONT oFnt7 COLOR CLR_BLACK
		
	Endif
	
	lMntTel := .t.
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CHANGE ³ Autor ³ Manoel / Andre        ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Controla Acessorios do Veiculo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHANGE(nOpcao,nLinha)

Local lRet := .t.

if nOpcao == 1
	
	aGener := {}
	aEspec := {}
	
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+aMarca[nLinha,1])
	While !Eof() .and. xFilial("VVR") == VVR->VVR_FILIAL .and. VVR->VVR_CODMAR == aMarca[nLinha,1]
		aadd(aGener,{VVR->VVR_DESCRI})
		dbSkip()
	Enddo
	if Len(aGener) == 0
		aGener := {{""}}
	Endif
	
	if oLbxSel2:nAt > Len(aGener)
		oLbxsel2:nAt := Len(aGener)
	Endif
	
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+aMarca[nLinha,1]+aGener[oLbxSel2:nAt,1])
	dbSelectArea("VV2")
	dbSetOrder(3)
	dbSeek(xFilial("VV2")+aMarca[nLinha,1]+VVR->VVR_GRUMOD)
	While !Eof() .and. xFilial("VV2") == VV2->VV2_FILIAL .and. VVR->VVR_CODMAR == aMarca[nLinha,1] .and. VV2->VV2_GRUMOD == VVR->VVR_GRUMOD
		aadd(aEspec,{VV2->VV2_MODVEI})
		dbSkip()
	Enddo
	if Len(aEspec) == 0
		aEspec := {{""}}
	Endif
	
Elseif nOpcao == 2
	
	aEspec := {}
	
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+aMarca[oLbxSel1:nAt,1]+aGener[nLinha,1])
	dbSelectArea("VV2")
	dbSetOrder(3)
	dbSeek(xFilial("VV2")+aMarca[oLbxSel1:nAt,1]+VVR->VVR_GRUMOD)
	While !Eof() .and. xFilial("VV2") == VV2->VV2_FILIAL .and. VVR->VVR_CODMAR == aMarca[oLbxSel1:nAt,1] .and. VV2->VV2_GRUMOD == VVR->VVR_GRUMOD
		aadd(aEspec,{VV2->VV2_MODVEI})
		dbSkip()
	Enddo
	if Len(aEspec) == 0
		aEspec := {{""}}
	Endif
	
Endif

oLbxSel2:SetArray(aGener)
oLbxSel2:bLine := { || { aGener[oLbxSel2:nAt,01] } }
oLbxSel2:Refresh()

oLbxSel3:SetArray(aespec)
oLbxSel3:bLine := { || { aEspec[oLbxSel3:nAt,01] } }
oLbxSel3:Refresh()

cCodMar := aMarca[oLbxSel1:nAt,1]
cGruMod := aGener[oLbxSel2:nAt,1]
cModVei := aEspec[oLbxSel3:nAt,1]

if cEstoque == "S"
	Fs_ValGet(1)
	Fs_ValGet(2)
	Fs_ValGet(7)
Else
	Do Case
		Case nOpcao == 1
			M->VV1_CODMAR := aMarca[nLinha,1]
		Case nOpcao == 2
			M->VV1_MODVEI := aEspec[oLbxSel3:nAt,1]
		Otherwise
			M->VV1_MODVEI := aEspec[oLbxSel3:nAt,1]
	EndCase
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTROVV³ Autor ³ Andre                ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtra Veiculos de acordo com parametros informados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTROVV(lObj,nCombo)

Local cont
Local aSituacao := {"0","3","4","6"}
Local nValorVda := 0
Local nDiasEst  := 0

cCond := 'VV1->VV1_SITVEI $ "0346"'

if !Empty(cCODMAR)
	cCond   := cCond + ' .and. alltrim(VV1->VV1_CODMAR) == "' + cCODMAR + '"'
Endif

if !Empty(cMODVEI)
	cCond := cCond + ' .and. alltrim(VV1->VV1_MODVEI) == "' + cMODVEI + '"'
Else
	if !Empty(cGruMod)
		cCond := cCond  + ' .and. alltrim(VV1->VV1_MODVEI) $ "' +  FS_GrModVei(cGruMod) + '"'
	Endif
Endif

if !Empty(cCOR)
	cCond := cCond  + ' .and. VV1->VV1_CORVEI == "' +  cCOR + '"'
Else
	if !Empty(cGruCor)
		cCond := cCond  + ' .and. VV1->VV1_CORVEI $ "' +  FS_GrCorVei(cGruCor) + '"'
	Endif
Endif

if !Empty(cCombus)
	cCond := cCond +  ' .and. VV1->VV1_COMVEI == "' +  Subs(cCombus,1,1) + '"'
Endif

if nAnoIni > 0
	cCond := cCond + ' .and. Subs(VV1->VV1_FABMOD,1,4) >= "' +  Str(nAnoIni,4) + '"'
Endif

if nAnoFin > 0
	cCond := cCond + ' .and. Subs(VV1->VV1_FABMOD,5,4) <= "' +  Str(nAnoFin,4) + '"'
Endif

if nValFxI > 0
	cCond := cCond + ' .and. FS_VALVDA() >= ' +  Str(nValFxI,12,2)
Endif

if nValFxF > 0
	cCond := cCond + ' .and. FS_VALVDA() <= ' +  Str(nValFxF,12,2)
Endif

if nKMFxa > 0
	cCond := cCond + ' .and. VV1->VV1_KILVEI <= ' + Str(nKMFxa,8)
Endif

if !Empty(cEstVeiF)
	cCond := cCond +  ' .and. VV1->VV1_ESTVEI == "' +  Subs(cEstVeiF,1,1) + '"'
Endif

VVC->(dbSetOrder(1))
VV2->(dbSetOrder(1))

aStruVV1 :={}
cSavAlias := alias()

dbSelectArea("VV1")
dbSetOrder(4)
For cont:=1 to Len(aSituacao)
	cSituacao := aSituacao[cont]
	
	//Posiciona primeiramente nos que possuem estoque
	if dbSeek(xFilial("VV1")+cSituacao)
		While !Eof() .and. VV1->VV1_FILIAL == xFilial("VV1") .and. VV1->VV1_SITVEI == cSituacao
			
			VV2->(dbSetOrder(1))
			VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			SB1->(dbSetOrder(7))
			if !SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
				dbSkip()
				Loop
			Endif
			
			if !Empty(cCond) .and. !(&cCond)
				dbSkip()
				Loop
			Endif
			
			if cTipFat <> ""
				if VV1->VV1_ESTVEI <> cTipFat
					dbSkip()
					Loop
				Endif
			Endif
			
			VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
			cDesCor := VVC->VVC_DESCRI
			VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			cDesMod := VV2->VV2_DESMOD
			
			lOk2 := .f.
			if VV1->VV1_RESERV $ "1/3" // 1-Reservado 3-venda futura
				lOk2 := .t.
				if !Empty(VV1->VV1_DTHVAL)
					dDatTmp := dToS(cToD(subs(VV1->VV1_DTHVAL,1,8)))
					dDatRes := Subs(dDatTmp,7,2) + "/" + Subs(dDatTmp,5,2) + "/" + Subs(dDatTmp,1,4)
					cHorTmp := subs(VV0->VV0_DTHEMI,10)
					if dDataBase > ctod(dDatRes)
						lOk2 := .f.
					Elseif dDataBase > ctod(dDatRes)
						if Time() > cHorTmp
							lOk2 := .f.
						Endif
					Endif
				Endif
			Endif
			
			nValorVda := 0
			if VV1->VV1_SUGVDA > 0
				nValorVda := VV1->VV1_SUGVDA
			Endif
			
			if nValorVda == 0
				nValorVda := FS_VALVDA()
			Endif
			
			dbSelectArea("VVD")
			dbSetOrder(1)
			if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
				while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
					if VVD->VVD_ATUCUS=="1"
						nValorVda += VVD->VVD_VALOR
					Endif
					dbSelectArea("VVD")
					dbSkip()
				Enddo
			Endif
			
			cLetra := "N"
			if lOk2
				cLetra := "B"
			Else
				if VV1->VV1_SITVEI == "3" //Remessa
					cLetra := "R"
				Endif
				if VV1->VV1_SITVEI == "4" //Consignado
					cLetra := "C"
				Endif
			Endif
			
			dbSelectArea("VVF")
			dbSetOrder(1)
			if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
				nDiasEst := (dDataBase-VVF->VVF_DATMOV)
			Endif
			
			cTerceiro := ""
			//Verifica se tem porder de terceiro
			if VV1->VV1_SITVEI == "3" //Remessa
				cSituacao := STR0330 //Remessa
				dbSelectArea("VVF")
				dbSetOrder(1)
				if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
					if VVF->VVF_OPEMOV == "2"
						cNtTerceiro := VVF->VVF_NUMNFI + " - " + FGX_UFSNF(VVF->VVF_SERNFI) + "    ( "+STR0284+" )"  //entrada
						if SA1->(dbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA))
							cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VVF->VVF_CODFOR+" )"
						Endif
					Else
						dbSelectArea("VV0")
						dbSetOrder(1)
						if dbSeek(xFilial("VV0")+VV1->VV1_NUMTRA)
							if VV0->VV0_OPEMOV == "3"
								cNtTerceiro := VV0->VV0_NUMNFI + " - " + FGX_UFSNF(VV0->VV0_SERNFI) + "    ( "+STR0336+" )" //saida
								if SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
									cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VV0->VV0_CODCLI+" )"
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
			
			if VV1->VV1_SITVEI == "4" //Consignado
				cSituacao := STR0331 //Consignado
				dbSelectArea("VVF")
				dbSetOrder(1)
				if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
					if VVF->VVF_OPEMOV == "4"
						cNtTerceiro := VVF->VVF_NUMNFI + " - " + FGX_UFSNF(VVF->VVF_SERNFI) + "    ( "+STR0284+" )"  //entrada
						if SA1->(dbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA))
							cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VVF->VVF_CODFOR+" )"
						Endif
					Else
						dbSelectArea("VV0")
						dbSetOrder(1)
						if dbSeek(xFilial("VV0")+VV1->VV1_NUMTRA)
							if VV0->VV0_OPEMOV == "5"
								cNtTerceiro := VV0->VV0_NUMNFI + " - " + FGX_UFSNF(VV0->VV0_SERNFI) + "    ( "+STR0336+" )" //saida
								if SA1->(dbSeek(xFilial("SA1")+VV0->VVF_CODCLI+VV0->VV0_LOJA))
									cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VV0->VV0_CODCLI+" )"
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
			
			aAdd(aStruVV1, { .f.,cLetra,!Empty(VV1->VV1_BITMAP),Str(nDiasEst,3),VV1->VV1_CHASSI,VV2->VV2_DESMOD,VV1->VV1_CODMAR,VVC->VVC_DESCRI,nValorVda,if(VV1->VV1_ESTVEI=="0",STR0316,STR0317),Subs(VV1->VV1_FABMOD,1,4),Subs(VV1->VV1_FABMOD,5,4),VV1->VV1_KILVEI, cTerceiro } )    //novo - usado
			
			dbSelectArea("VV1")
			dbSkip()
		EndDo
	Endif
Next

dbSelectArea("VV1")
dbSetOrder(1)

if len(aStruVV1) == 0
	aAdd(aStruVV1, { .f.,"N",.f.," "," "," "," "," ",0,"","","",0,"" } )
Endif

Asort(aStruVV1,,,{|x,y| x[4] > y[4] })

if cEstoque == "S" .and. (lObj == Nil .or. lObj)
	oLbox:nAt := 1
	oLbox:SetArray(aStruVV1)
	oLbox:bLine := { || { if(aStruVV1[oLbox:nAt,01] == .f.,oNo,oTik),;
	iif(aStruVV1[oLbox:nAt,02] == "N",oNo,fs_corbrowse(oLbox:nAt)),;
	iif(aStruVV1[oLbox:nAt,03] == .f.,oNada,oFoto),;
	aStruVV1[oLbox:nAt,04],;
	aStruVV1[oLbox:nAt,05],;
	aStruVV1[oLbox:nAt,06],;
	aStruVV1[oLbox:nAt,07],;
	aStruVV1[oLbox:nAt,08],;
	Fg_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"9,999,999.99")),;
	aStruVV1[oLbox:nAt,10],;
	aStruVV1[oLbox:nAt,11],;
	aStruVV1[oLbox:nAt,12],;
	aStruVV1[oLbox:nAt,13],;
	aStruVV1[oLbox:nAt,14] } }
	oLBox:Refresh()
Endif

if nCombo == 1
	aGener := {{""}}
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+cCODMAR)
	While !Eof() .and. xFilial("VVR") == VVR->VVR_FILIAL .and. alltrim(VVR->VVR_CODMAR) == cCODMAR
		if aScan(aGener,VVR->VVR_DESCRI) = 0
			aadd(aGener,VVR->VVR_DESCRI)
		Endif
		dbSkip()
	Enddo
	cbxGruMod:AITEMS := aGener
	cModVei := ""
Endif

if !Empty(cGRUMOD) .and. nCombo == 2
	aEspec := {""}
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+cCODMAR+SPACE(TamSx3("VV1_CODMAR")[1]-len(cCODMAR))+cGRUMOD)
	dbSelectArea("VV2")
	dbSetOrder(3)
	dbSeek(xFilial("VV2")+cCODMAR+SPACE(TamSx3("VV1_CODMAR")[1]-len(cCODMAR))+VVR->VVR_GRUMOD)
	While !Eof() .and. xFilial("VV2") == VV2->VV2_FILIAL .and. alltrim(VVR->VVR_CODMAR) == cCODMAR .and. VV2->VV2_GRUMOD == VVR->VVR_GRUMOD
		if aScan(aEspec,VV2->VV2_DESMOD) = 0
			aadd(aEspec,VV2->VV2_DESMOD)
		Endif
		dbSkip()
	Enddo
	cbxModVei:AITEMS := aEspec
Endif

dbSelectArea(cSavAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALGET ³ Autor ³ Andre                 ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao de alguns campos da aba de filtro                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALGET(Arg)

if Arg == 1
	
	if Empty(cCODMAR)
		cDesMar := Space(15)
		Return .t.
	Else
		VE1->(dbSetOrder(1))
		if !VE1->(dbSeek(xfilial("VE1")+cCODMAR))
			help(" ",1,"MCNCADM010")
			Return .f.
		Else
			cDesMar := VE1->VE1_DESMAR
			FS_FILTROVV()
			Return .t.
		Endif
	Endif
	
Elseif Arg == 2
	
	if Empty(cMODVEI)
		cDesMod := Space(15)
		Return .t.
	Else
		if !Empty(cCODMAR)
			VV2->(dbSetOrder(1))
			if !VV2->(dbSeek(xFilial("VV2")+cCODMAR+cMODVEI))
				Help(" ",1,"MVNCADM010")
				Return .f.
			Else
				cDesMod := VV2->VV2_DESMOD
				FS_FILTROVV()
				Return .t.
			Endif
		Else
			cDesMod := VV2->VV2_DESMOD
			Return .t.
		Endif
	Endif
	
Elseif Arg == 3
	
	If Empty(cCOR)
		cDesCor := Space(19)
		FS_FILTROVV()
		Return .t.
	Else
		If !Empty(cCODMAR)
			VVC->(dbSetOrder(1))
			If !VVC->(dbSeek(xFilial("VVC")+cCODMAR+cCOR))
				Help(" ",1,"CVNCADM010")
				Return .f.
			Else
				cDesCor := Subs(VVC->VVC_DESCRI,1,19)
				FS_FILTROVV()
				Return .t.
			Endif
		Else
			cDesCor := Subs(VVC->VVC_DESCRI,1,19)
			FS_FILTROVV()
			Return .t.
		Endif
		
	Endif
	
Elseif Arg == 4
	
	If !(nAnoIni >= year(dDataBase)-100) .and. nAnoIni != 0
		Return(.f.)
	Else
		FS_FILTROVV()
		Return(.t.)
	Endif
	
Elseif Arg == 5
	
	if nAnoIni > 0
		If !( nAnoFin >= nAnoIni)
			Return(.f.)
		Else
			FS_FILTROVV()
			Return(.t.)
		Endif
	Else
		if !(nAnoFin >= year(dDataBase)-100) .and. nAnoIni != 0
			Return(.f.)
		Else
			FS_FILTROVV()
			Return(.t.)
		Endif
	Endif
	
Elseif Arg == 6
	
	If nValFxF < nValFxI
		Return(.f.)
	Else
		FS_FILTROVV()
		Return(.t.)
	Endif
	
Elseif Arg == 7
	
	if Empty(cGruMod)
		cDesGMod := Space(15)
		Return .t.
	Else
		VVR->(dbSetOrder(2))
		if !VVR->(dbSeek(xFilial("VVR")+cCodMar+cGruMod))
			Return .f.
		Else
			cDesGMod := VVR->VVR_DESCRI
			FS_FILTROVV()
			Return .t.
		Endif
	Endif
	
Elseif Arg == 8
	
	if Empty(cGruCor)
		cDesGCor := Space(15)
		FS_FILTROVV()
		Return .t.
	Else
		VVQ->(dbSetOrder(2))
		if !VVQ->(dbSeek(xFilial("VVQ")+cGruCor))
			Return .f.
		Else
			cDesGCor := VVQ->VVQ_DESCRI
			FS_FILTROVV()
			Return .t.
		Endif
	Endif
	
Elseif Arg == 9
	
	If nKMFxa <=0
		Return(.f.)
	Else
		FS_FILTROVV()
	Endif
	
Elseif Arg == 10
	
	if !Empty(cCombus)
		FS_FILTROVV()
	Endif
	
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_REMTRA ³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia / Remessa de Veiculos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_REMTRA(cAlias, nReg, nOpc)

Local oForPag, oCodCli,oLojaCli, oValIcm
Local oScroll, oChassi, oMarca , oModelo, oCor , oValVei
Local oAliIcm, oVbaIcm, oTipFat, oCodTes, oObserv, oCodVen

nAliPis    := GETMV("MV_TXPIS")  / 100
nAliCof    := GETMV("MV_TXCOFIN")/ 100
lDigVda := .t.

aTransp  := {OemToAnsi(STR0128),OemToAnsi(STR0129)}

nOpcaX    := 0

If oScroll # NIL
	DeleteObject(oScroll)
EndIf

aTipFat  := {OemToAnsi(STR0037),OemToAnsi(STR0038)}
@ 2,.1 SCROLLBOX oScroll VERTICAL SIZE 169,315 OF oFolderV:aDialogs[1] BORDER PIXEL

If nOpc == 3  .and. lTelVdaSim == .f. .and. ( (oFolderV:nOption == 2 .and. cTipSai == "0") .or. (oFolderV:nOption == 1 .and. cTipSai $ "2"+"3" ) )
	
	if M->VVA_CHASSI == Space(25)
		
		lTelVdaSim := .t.
		M->VVA_VCAVEI := 0
		M->VVA_ACESSO := 0
		M->VVA_JUREST := 0
		nCusAce		  := 0
		
		If cTipFat == "0"     //Novo
			wstr     := OemToAnsi(STR0039)               //Venda de Veiculos Novos
		Elseif cTipFat == "1" //Usado
			wstr     := OemToAnsi(STR0040)               //Venda de Veiculos Usados
		Endif
		
		cEstoque := "S"       //Sim
		
	Endif
	
Endif

If cTipFat == Space(01)
	cTipFat := VV1->VV1_ESTVEI
Endif

if lFecTel
	Return .f.
Endif
Lin := 11

lValGeral := inclui .or. altera

@ Lin,004 SAY OemToAnsi(STR0051)  OF oScroll PIXEL COLOR CLR_BLUE //Cliente
@ Lin,044 MSGET oCodCli VAR M->VV0_CODCLI PICTURE "@9" F3 "VSC" VALID VLD(7) SIZE 40,4  OF oScroll PIXEL  COLOR CLR_BLACK when lValGeral
@ Lin,174 SAY OemToAnsi(STR0094)  OF oScroll PIXEL COLOR CLR_BLUE //Loja
@ Lin,214 MSGET oLojaCli VAR M->VV0_LOJA PICTURE "@9" VALID VLD(18) SIZE 2,4  OF oScroll PIXEL  COLOR CLR_BLACK  when lValGeral //3rd valdir
@ Lin,237 SAY oNomCli VAR cNomCli OF oScroll PIXEL SIZE 48,6 COLOR CLR_BLUE FONT oFnt4
Lin := lin + 13

@ Lin,004 SAY OemToAnsi(STR0057)  OF oScroll PIXEL COLOR CLR_BLUE //Vendedor
@ Lin,044 MSGET oCodVen VAR M->VV0_CODVEN PICTURE "@E9" F3 "SA3" VALID VLD(15) SIZE 40,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
@ Lin,084 SAY cNomVen OF oScroll PIXEL SIZE 78,6 COLOR CLR_BLUE FONT oFnt4
@ Lin,174 SAY OemToAnsi(STR0047) OF oScroll PIXEL COLOR CLR_BLUE // TES
@ Lin,214 MSGET oCodtes VAR M->VVA_CODTES PICTURE "@!S3" F3 "SF4" VALID VLD(17) SIZE 40,4  OF oScroll PIXEL  COLOR CLR_BLACK when  lValGeral
Lin := lin + 13

@ Lin,004 SAY OemToAnsi(STR0054)  OF oScroll PIXEL COLOR CLR_BLUE //Condicao Pagto
@ Lin,044 MSGET oForPag VAR M->VV0_FORPAG PICTURE "@!" F3 "SE4" VALID VLD(11) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when  .f.
@ Lin,084 SAY cDesFpg OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
Lin := lin + 13

@ Lin,004 SAY OemToAnsi(STR0078)  OF oScroll PIXEL COLOR CLR_BLUE //Banco
@ Lin,044 MSGET oCodBco VAR M->VV0_CODBCO PICTURE "@!" F3 "A61" VALID VLD(16) SIZE 40,4 OF oScroll PIXEL COLOR CLR_BLACK when .f.
@ Lin,084 SAY cNomBco OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
@ Lin,174 SAY OemToAnsi(STR0087)  OF oScroll PIXEL COLOR CLR_BLUE //Agencia
@ Lin,214 MSGET oCodAge VAR M->VV0_CODAGE PICTURE "@!" SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when .f.
Lin := lin + 13

@  62, 002 TO 142,312 LABEL "" OF oScroll PIXEL
Lin := lin + 6

//Dados do Veiculo
cNovUsa := cTipFat
@ Lin,004 SAY OemToAnsi(STR0088)  OF oScroll PIXEL COLOR CLR_BLUE //Chassi
@ Lin,044 MSGET oChassi VAR M->VVA_CHASSI PICTURE "@!S25" F3 "V12" VALID VLD(1) SIZE 83,4 OF oScroll PIXEL  COLOR CLR_BLACK when  lValGeral
@ Lin,174 SAY OemToAnsi(STR0062) OF oScroll PIXEL COLOR CLR_BLUE //Chassi Interno
@ Lin,214 MSGET M->VVA_CHAINT PICTURE "@!S15" SIZE 55,4 OF oScroll PIXEL  COLOR CLR_BLACK when .f.
Lin := lin + 13

@ Lin,004 SAY OemToAnsi(STR0063)  OF oScroll PIXEL COLOR CLR_BLUE //Marca
@ Lin,044 MSGET oMarca VAR M->VV1_CODMAR PICTURE "@!" F3 "VE1" VALID VLD(2) SIZE 40,4 OF oScroll PIXEL  COLOR CLR_BLACK when cEstoque == "N"  .and.  lValGeral .and. cTipSai # "4" //Devolucao
@ Lin,084 SAY cDesMar OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
@ Lin,174 SAY OemToAnsi(STR0064) OF oScroll PIXEL COLOR CLR_BLUE //Modelo
@ Lin,214 MSGET oModelo VAR M->VV1_MODVEI PICTURE "@!" F3 "MCV" VALID VLD(3) SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when cEstoque == "N" .and.  lValGeral .and. cTipSai # "4" //Devolucao
Lin := lin + 13

@ Lin,004 SAY OemToAnsi(STR0081) OF oScroll PIXEL COLOR CLR_BLUE //Vlr Movto
@ Lin,044 MSGET oValVei VAR M->VVA_VALVDA PICTURE "@E 999,999,999.99" VALID VLD(13) SIZE 55,4 OF oScroll PIXEL  COLOR CLR_BLACK when lValGeral
@ Lin,174 SAY OemToAnsi(STR0085)  OF oScroll PIXEL COLOR CLR_BLUE //Base do Icms
@ Lin,214 MSGET oVbaIcm VAR M->VVA_VBAICM PICTURE "@E 999,999,999.99"   SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when !cTipSai $ "2" .and.  lValGeral .and. lBaseIcm     //Transferencia
Lin := Lin + 13

@ Lin,004 SAY OemToAnsi(STR0076)  OF oScroll PIXEL COLOR CLR_BLUE //Aliquota ICMS
@ Lin,044 MSGET oAliIcm VAR M->VVA_ALIICM PICTURE "@E 999.99" VALID VLD(10)  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral .and. cTipSai # "4" .and. lValIcm  //Devolucao
@ Lin,174 SAY OemToAnsi(STR0086)  OF oScroll PIXEL COLOR CLR_BLUE //ICMS
@ Lin,214 MSGET oValIcm VAR M->VVA_ICMVEN PICTURE "@E 999,999.99"  OF oScroll PIXEL COLOR CLR_BLUE when .f.
Lin += 2

@ Lin,258 BUTTON oObserv PROMPT OemToAnsi(STR0077)  OF oScroll SIZE 43,11 PIXEL  ACTION FS_ObsVei(nOpc)  //Observacoes

@ 001, 002 TO 150,312 LABEL "" OF oScroll PIXEL

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GRAVA010³ Autor ³ Manoel / Andre       ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava Arquivo VV0 - Movimentacao de Saidas/Simulacoes       ³±±
±±³          ³Grava Arquivo VVA - Simulacao / Venda / Remessa / Transfers ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1 = Tipo de Gravacao:                                       ³±±
±±³          ³    "S" = Arquivos da Simulacao                             ³±±
±±³          ³    "D" = Deleta Arquivo Gerado p/ Simulacao                ³±±
±±³          ³    "G" = Grava a Simulacao/Proposta Definitivamente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVA010(cTip,nOpc,lLib)

Local _cCliente, _cLoja, _cTipo
Local cOpcao       := OemToAnsi(STR0260)
Local cMarK        := GetMark()
Local bCodBlock    := {||SC9->C9_OK:=cMark}
Local lRetRec      := .f.
//Local aCabPv       := {}
//Local aItePv       := {}
Local aIteTempPv   := {}
Local aPvlNfs      := {}
Local aVetTra      := {}
Local aMata410Cab  := {}
Local aMata410Itens:= {}
Local bCampo       := { |nCPO| Field(nCPO) }
Local x_,nCntFor,i := 0

Private aCabPv     := {}
Private aItePv     := {}

if nOpc == 2
	Return (.t.)
Endif

If Type("cNumTra") == "U"
	cNumTra := ""
	if nOpc <> 3
		cNumTra := VV0->VV0_NUMTRA
	Endif
Endif

Default lLib := .f.

If Type("cIdeSB6") == "U"
	cIdeSB6 := space(6)
EndIf

//Ponto de Entrada - Orcamento
If ExistBlock("INSEREORC")
	ExecBlock("INSEREORC",.f.,.f.)
Endif

//Ponto de Entrada - OS
If ExistBlock("INSEREOSV")
	ExecBlock("INSEREOSV",.f.,.f.)
Endif

lDeleta     := .f.
lMsHelpAuto := .t.
lMsErroAuto := .f.

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

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA)

if !Empty(M->VV0_CHASSI)
	VV1->(dbSetOrder(2))
	VV1->(dbSeek(xFilial("VV1")+M->VV0_CHASSI))
	M->VV0_CHAINT := VV1->VV1_CHAINT
	M->VVA_CHASSI := VV1->VV1_CHASSI
	M->VVA_CHAINT := VV1->VV1_CHAINT
	VV1->(dbSetOrder(1))
Endif

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

if cTip == "G" .and. !lLib
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Geracao e Liberacao dos Pedidos de Venda                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VV0->VV0_OPEMOV # "1" .and. M->VV0_AUTFAT # "0"    // Se nao for Simulacao e Autorizou Faturamento
		
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
		If cTipSai <> "6" // CLAUDIA
			if cTipFat <> "2"   //Faturamento Direto	
				If SF4->F4_ESTOQUE == "S"
					dbSelectArea("SB2")
					dbSetOrder(1)
					if dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei)
						if SB2->B2_QATU <= 0
							MsgInfo(STR0337 ,STR0015) //Veiculo nao esta no Estoque! - Atencao!
							DisarmTransaction()
							Break
						Endif
					Else
						MsgInfo(STR0337 ,STR0015) //Veiculo nao esta no Estoque! - Atencao!
						DisarmTransaction()
						Break
					Endif
				Endif
			Endif
		Else
			// VERIFICA SE A TES DE ENTRADA CONTROLOU ESTOQUE PARA
			// VERIFICAR SE A TES DE SAIDA TAMBEM DEVERA CONTROLAR ESTOQUE
			if SD1->(dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD))
				SF4->(dbSetOrder(1))
				If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES)) .AND. cTipFat <> "2" .AND. SF4->F4_ESTOQUE == "S"
					dbSelectArea("SB2")
					dbSetOrder(1)
					if dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei)
						if SB2->B2_QATU <= 0
							MsgInfo(STR0337 ,STR0015)  //Veiculo nao esta no Estoque - atencao
							DisarmTransaction()
							Break
						Endif
					Else
						MsgInfo(STR0337 ,STR0015) //Veiculo nao esta no Estoque - Atencao!
						DisarmTransaction()
						Break
					Endif
				Endif
			EndIF
		EndIF
		if cTipSai == "0" .and. cTipFat <> "2"
			if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "S"	//Integrado com o Sigaloja ?
				if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
					IncProc(OemToAnsi(STR0338)) //Gerando Integracao com o Loja
					FS_INTVLOJA()
				Endif
				Return( .t. )
			EndIf
		Endif
		
		If cTipSai == "4" //Devolucao
			cTipPed := "D"
		ElseIf cTipSai == "6" //Devolucao Remessa
			cTipPed := "D"
		Else
			cTipPed := "N"
		EndIf
		
		IncProc(STR0225) //Gerando Pedido
		
		VE4->(dbSetOrder(1))
		VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
		if cTipFat == "2"     //Faturamento Direto
			SE4->(dbSetOrder(1))
			SE4->(dbSeek(xFilial("SE4")))
			while SE4->E4_FILIAL == xFilial("SE4") .and. SE4->(!eof())
				if SE4->E4_TIPO # "A" .and. Alltrim(SE4->E4_COND) == "0"
					Exit
				Endif
				SE4->(dbSkip())
			Enddo
			M->VV0_FORPAG := SE4->E4_CODIGO
			
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+M->VV0_CLIFTD+M->VV0_LOJFTD)
			
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+M->VV0_CHAINT)
			
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
			cLocal := SB1->B1_LOCPAD
			
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial("SA3")+M->VV0_CODVEN)
			
			if (M->VV0_OPEMOV == "0" .and. cParPrg == "2" .and. Empty(VV0->VV0_NUMPED)) .or. (M->VV0_OPEMOV $ "2346" .and. Empty(VV0->VV0_NUMPED))//Transf/Remessa/Devolucao
				M->VV0_NUMPED:= CriaVar("C5_NUM")
			Endif
			
			//Pega a classificacao fiscal de acordo com o estado do cliente
			cCFiscal := FG_CLAFIS(M->VVA_CODTES)
			if Empty(cCFiscal)
				cMsg := STR0224
				lMsErroAuto := .t.
				DisarmTransaction()
				Break
			Endif
			
			_cCliente := SA1->A1_COD
			_cLoja    := SA1->A1_LOJA
			_cTipo    := SA1->A1_TIPO
			
			//Cabecalho
			aAdd(aCabPV,{"C5_NUM"    ,M->VV0_NUMPED,Nil}) // Numero do pedido
			aAdd(aCabPV,{"C5_TIPO"   ,cTipPed      ,Nil}) // Tipo de pedido
			aAdd(aCabPV,{"C5_CLIENTE",_cCliente    ,Nil}) // Codigo do cliente
			aAdd(aCabPV,{"C5_LOJAENT",_cLoja       ,Nil}) // Loja para entrada
			aAdd(aCabPV,{"C5_LOJACLI",_cLoja       ,Nil}) // Loja do cliente
			aAdd(aCabPV,{"C5_CONDPAG",RetCondVei() ,Nil}) // Codigo da condicao de pagamanto
			aAdd(aCabPV,{"C5_VEND1"  ,M->VV0_CODVEN,Nil}) // Codigo do vendedor
			aAdd(aCabPV,{"C5_EMISSAO",M->VV0_DATMOV,Nil}) // Data de emissao
			aAdd(aCabPV,{"C5_TIPOCLI",_cTipo        ,Nil}) // Tipo do Cliente
			aAdd(aCabPV,{"C5_DESC1"  ,0             ,Nil}) // Percentual de Desconto
			aAdd(aCabPV,{"C5_BANCO"  ,M->VV0_CODBCO,Nil}) // Banco
			aAdd(aCabPV,{"C5_INCISS" ,"N"           ,Nil}) // ISS Incluso
			aAdd(aCabPV,{"C5_TIPLIB" ,"2"           ,Nil}) // Tipo do Cliente
			aAdd(aCabPV,{"C5_MOEDA"  ,1             ,Nil}) // Moeda
			aAdd(aCabPV,{"C5_LIBEROK","S"           ,Nil}) // Liberacao Total
			aAdd(aCabPV,{"C5_COMIS1" ,0             ,Nil}) // Percentual de Comissao
			aAdd(aCabPV,{"C5_DESPESA",M->VV0_DESACE,Nil}) // Percentual de Comissao
			
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("SC5")
			While !Eof().and.(x3_arquivo=="SC5")
				wVar := "M->"+x3_campo
				&wVar:= CriaVar(x3_campo)
				dbSkip()
			EndDo
			
			For x_:=1 to Len(aCabPV)
				Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
			Next
			
			//Items
			SB1->(dbSetOrder(7))
			dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
			SB1->(dbSetOrder(1))

			SF4->(dbSeek(xFilial("SF4")+M->VVA_CODTES))
	
			aAdd(aIteTempPV,{"C6_NUM"    ,M->VV0_NUMPED  ,Nil}) // Numero do Pedido
			aAdd(aIteTempPV,{"C6_ITEM"   ,"01"           ,Nil}) // Numero do Item no Pedido
			aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD    ,Nil}) // Codigo do Produto
			aAdd(aIteTempPV,{"C6_QTDVEN" ,1              ,Nil}) // Quantidade Vendida
			aAdd(aIteTempPV,{"C6_PRUNIT" ,M->VVA_VALCVD  ,Nil}) // Preco Unitario do Produto
			aAdd(aIteTempPV,{"C6_PRCVEN" ,M->VVA_VALCVD  ,Nil}) // Preco Unitario Liquido
			aAdd(aIteTempPV,{"C6_VALOR"  ,M->VVA_VALCVD  ,Nil}) // Valor Total do Item
			aAdd(aIteTempPV,{"C6_ENTREG" ,M->VV0_DATMOV  ,Nil}) // Data da Entrega
			aAdd(aIteTempPV,{"C6_UM"     ,"UN"         	 ,Nil}) // Unidade de Medida Primar.
			aAdd(aIteTempPV,{"C6_TES"    ,M->VVA_CODTES  ,Nil}) // Tipo de Entrada/Saida do Item
			aAdd(aIteTempPV,{"C6_LOCAL"  ,cLocal         ,Nil}) // Almoxarifado
			aAdd(aIteTempPV,{"C6_CF"     ,cCFiscal       ,Nil}) // CFO
			aAdd(aIteTempPV,{"C6_CLASFIS",Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB,Nil}) // Situacao Tributaria
			aAdd(aIteTempPV,{"C6_VALDESC",0              ,Nil}) // Valor do Desconto
			aAdd(aIteTempPV,{"C6_DESCONT",0              ,Nil}) // Percentual de Desconto
			aAdd(aIteTempPV,{"C6_COMIS1" ,0              ,Nil}) // Comissao Vendedor
			aAdd(aIteTempPV,{"C6_DESCRI" ,SB1->B1_DESC  ,Nil}) // Descricao do Produto
			aAdd(aIteTempPV,{"C6_CLI"    ,_cCliente     ,Nil}) // Cliente
			aAdd(aIteTempPV,{"C6_LOJA"   ,_cLoja        ,Nil}) // Loja do Cliente
			aAdd(aIteTempPV,{"C6_QTDEMP" ,1              ,Nil}) // Quantidade Empenhada
			
		Else
			
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA)
			
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+M->VV0_CHAINT)
			
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+GetMv("MV_GRUVEI")+M->VV0_CHAINT)
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei)
			
//			dbSelectArea("SB1")
//			dbSetOrder(7)
//			dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
//			cLocal := SB1->B1_LOCPAD
			
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial("SA3")+M->VV0_CODVEN)
			
			M->VV0_PERDES := (M->VV0_VALDES/(M->VV0_VALMOV+M->VV0_VALDES))*100
			
			// Transferencia / Remessa / Devolucao
			if (M->VV0_OPEMOV == "0" .and. cParPrg == "2" .and. Empty(VV0->VV0_NUMPED)) .or. (M->VV0_OPEMOV $ "2346" .and. Empty(VV0->VV0_NUMPED))
				M->VV0_NUMPED := CriaVar("C5_NUM")
			Endif
			
			// Pega a classificacao fiscal de acordo com o estado do cliente
			cCFiscal := FG_CLAFIS(M->VV0_CODTES)
			if Empty(cCFiscal)
				cMsg := STR0224
				lMsErroAuto := .t.
				DisarmTransaction()
				Break
			Endif
			
			_cCliente := SA1->A1_COD
			_cLoja    := SA1->A1_LOJA
			_cTipo    := SA1->A1_TIPO
			
//			if cTipSai == "6" //Retorno da Entrada por Remessa
			if cTipSai $ "6.4" //Retorno da Entrada por Remessa.Devolucao ***Otavio 10/06/2009***
				_cCliente := SA2->A2_COD
				_cLoja    := SA2->A2_LOJA
				_cTipo    := SA2->A2_TIPO
				if !(_cTipo $ "FX") //Fisica = Consumidor Final
					_cTipo := "R" //Revendedor
				Endif
			Endif
			
			// Acerto do CFO
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+M->VV0_CODTES)
			If cTipPed $ "DB"
				cCFiscal := IIF(_cTipo!="X",iif(SA2->A2_EST == GetMv("MV_ESTADO"),SF4->F4_CF,"6"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"7"+Subs(F4_CF,2,LEN(SF4->F4_CF)-1))
			Else
				cCFiscal := IIF(_cTipo!="X",iif(SA1->A1_EST == GetMv("MV_ESTADO"),SF4->F4_CF,"6"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"7"+Subs(F4_CF,2,LEN(SF4->F4_CF)-1))
			EndIf
			
			// Cabecalho
			aAdd(aCabPV,{"C5_NUM"    ,M->VV0_NUMPED  ,Nil})   // Numero do pedido
			aAdd(aCabPV,{"C5_TIPO"   ,cTipPed        ,Nil})   // Tipo de pedido
			aAdd(aCabPV,{"C5_CLIENTE",_cCliente      ,Nil})   // Codigo do cliente
			aAdd(aCabPV,{"C5_LOJAENT",_cLoja         ,Nil})   // Loja para entrada
			aAdd(aCabPV,{"C5_LOJACLI",_cLoja         ,Nil})   // Loja do cliente
			aAdd(aCabPV,{"C5_CONDPAG",RetCondVei()   ,Nil})   // Codigo da condicao de pagamanto
			aAdd(aCabPV,{"C5_VEND1"  ,M->VV0_CODVEN  ,Nil})   // Codigo do vendedor
			aAdd(aCabPV,{"C5_EMISSAO",M->VV0_DATMOV  ,Nil})   // Data de emissao
			aAdd(aCabPV,{"C5_TIPOCLI",_cTipo         ,Nil})   // Tipo do Cliente
			aAdd(aCabPV,{"C5_BANCO"  ,M->VV0_CODBCO  ,Nil})   // Banco
			aAdd(aCabPV,{"C5_INCISS" ,"N"            ,Nil})   // ISS Incluso
			aAdd(aCabPV,{"C5_TIPLIB" ,"2"            ,Nil})   // Tipo do Cliente
			aAdd(aCabPV,{"C5_MOEDA"  ,1              ,Nil})   // Moeda
			aAdd(aCabPV,{"C5_LIBEROK","S"            ,Nil})   // Liberacao Total
			aAdd(aCabPV,{"C5_COMIS1" ,0              ,Nil})   // Percentual de Comissao

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rubens - 31/07/2009                                              ³
			//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
			//³FNC 18018/2009                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aCabPV,{"C5_TRANSP" ,M->VV0_CODTRA  ,Nil})   // Transportadora 
			IF !Empty(M->VV0_TPFRET)
				aAdd(aCabPV,{"C5_TPFRETE",M->VV0_TPFRET  ,Nil})   // Tipo  do Frete 
			ENDIF
			aAdd(aCabPV,{"C5_FRETE"  ,M->VVA_VALFRE  ,Nil})   // Valor do Frete 
 			
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("SC5")
			While !Eof().and.(x3_arquivo=="SC5")
				wVar := "M->"+x3_campo
				&wVar:= CriaVar(x3_campo)
				dbSkip()
			EndDo
			
			For x_:=1 to Len(aCabPV)
				Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
			Next
			
			// Items
			SB1->(dbSetOrder(7))
			SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
			SB1->(dbSetOrder(1))
			cLocal := SB1->B1_LOCPAD
			
			aAdd(aIteTempPV,{"C6_NUM"    ,M->VV0_NUMPED,Nil})  // Numero do Pedido
			aAdd(aIteTempPV,{"C6_ITEM"   ,"01"         ,Nil})  // Numero do Item no Pedido
			aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD  ,Nil})  // Codigo do Produto
			aAdd(aIteTempPV,{"C6_QTDVEN" ,1            ,Nil})  // Quantidade Vendida
			aAdd(aIteTempPV,{"C6_PRUNIT" ,M->VV0_VALMOV+M->VV0_VALDES,Nil}) // Preco Unitario do Produto
			aAdd(aIteTempPV,{"C6_PRCVEN" ,M->VV0_VALMOV+M->VV0_VALDES,Nil}) // Preco Unitario Liquido
			aAdd(aIteTempPV,{"C6_VALOR"  ,M->VV0_VALMOV+M->VV0_VALDES,Nil}) // Valor Total do Item
			aAdd(aIteTempPV,{"C6_ENTREG" ,M->VV0_DATMOV  ,Nil})  // Data da Entrega
			aAdd(aIteTempPV,{"C6_UM"     ,"UN"           ,Nil})  // Unidade de Medida Primar.
			aAdd(aIteTempPV,{"C6_TES"    ,M->VV0_CODTES  ,Nil})  // Tipo de Entrada/Saida do Item
			aAdd(aIteTempPV,{"C6_LOCAL"  ,cLocal         ,Nil})  // Almoxarifado
			aAdd(aIteTempPV,{"C6_CF"     ,cCFiscal       ,Nil})  // CFO
			aAdd(aIteTempPV,{"C6_VALDESC",M->VV0_VALDES  ,Nil})  // Valor do Desconto
			aAdd(aIteTempPV,{"C6_COMIS1" ,0              ,Nil})  // Comissao Vendedor
			aAdd(aIteTempPV,{"C6_DESCRI" ,M->VV0_CHASSI  ,Nil})  // Descricao do Produto
			aAdd(aIteTempPV,{"C6_CLI"    ,_cCliente      ,Nil})  // Cliente
			aAdd(aIteTempPV,{"C6_LOJA"   ,_cLoja         ,Nil})  // Loja do Cliente
			aAdd(aIteTempPV,{"C6_QTDEMP" ,1              ,Nil})  // Quantidade Empenhada
		Endif
		
		if cTipSai $ "46" .or. Type("cNfiOri") <> "U" .and. !Empty(cNfiOri) //Devolucao
			if cTipSai == "6" .and. cTipPed == "D" //Devolucao Remessa //Retorno Remessa
				if VVG->VVG_VALIPI > 0
					aAdd(aIteTempPV,{"C6_IPIDEV",VVG->VVG_VALIPI,Nil})  // Loja do Cliente
				Endif
			Endif
			aAdd(aIteTempPV,{"C6_NFORI"   ,cNfiOri        ,Nil})
			aAdd(aIteTempPV,{"C6_SERIORI" ,cSerOri        ,Nil})
			aAdd(aIteTempPV,{"C6_ITEMORI" ,cIteNFOri      ,Nil})
			If cTipSai # "4" //Diferente de Devolucao
				aAdd(aIteTempPV,{"C6_IDENTB6" ,cIdeSB6        ,Nil})
			EndIf
		Endif
		
		aAdd(aItePv,aClone(aIteTempPV))
		aIteTempPV := {}
		
		if cParPrg == "2"  .or. ; // Proposta
			(M->VV0_OPEMOV $ "2346") // Transf/Remessa/Devolucao
			
			If lAbortPrint
				If MsgYesNo(OemToAnsi(STR0226),OemToAnsi(STR0199))
					Help("  ",1,"M160PROABO")
					lRet := .f.
					DisarmTransaction()
					Break
				Else
					lAbortPrint := .F.
				EndIf
			EndIf
			
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			if SC5->(dbSeek(xFilial("SC5")+M->VV0_NUMPED))
				aMata410Cab   := {{"C5_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do pedido SC5
				aMata410Itens := {{"C6_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do Pedido SC6
				
				//Exclui Pedido
				SC9->(dbSetOrder(1))
				SC9->(dbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
				While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
					SC9->(a460Estorna())
					SC9->(dbSkip())
				EndDo
				
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5) //Cancela Pedido
			Endif
			
			lInclui := inclui
			inclui  := .t.

			if ExistBlock("PEDVM010")
				ExecBlock("PEDVM010",.f.,.f.)
			Endif

			FG_X3ORD("C",,aCabPv)
			FG_X3ORD("I",,aItePv)
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3) //Faz Liberacao do Pedido se LiberOk = "S" e QtdLib = QtdEmp
			inclui  := lInclui
			if lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			Endif
			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Se nao for Simulacao e Autorizou Faturamento
		//Transferencia / Remessa / Devolucao
		If M->VV0_OPEMOV # "1" .and. M->VV0_AUTFAT # "0" .or. M->VV0_OPEMOV $ "2346"
			
			IncProc(STR0227)  // Gerando Nota Fiscal
			
			If lAbortPrint
				If MsgYesNo(OemToAnsi(STR0228),OemToAnsi(STR0199))
					Help("  ",1,"M160PROABO")
					lRet := .f.
					DisarmTransaction()
					Break
				Else
					lAbortPrint := .F.
				EndIf
			EndIf
			
			cNumPed := M->VV0_NUMPED
			
			lCredito := .t.
			lEstoque := .t.
			lLiber   := .t.
			lTransf  := .f.
			
			
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+cNumPed+"01")
			PERGUNTE("MTA410",.f.)
			While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
				nQtdLib := SC6->C6_QTDVEN
				cChavSC9 := cNumPed+SC6->C6_ITEM
				FG_Seek("SC9","cChavSC9")
				if MV_PAR01 != 1 
					nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
				endif
				dbSelectArea("SC6")
				dbSkip()
			Enddo
			
			//Posicionamento p/ calcular o Custo do Veiculo
			VV1->(dbSeek(xFilial("VV1")+M->VV0_CHAINT))
			VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
			
			VVF->(dbSetOrder(1))
			VVF->(dbSeek(xFilial("VVF")+VV1->VV1_TRACPA ))
			VVG->(dbSetOrder(1))
			VVG->(dbSeek(xFilial("VVG")+VVF->VVF_TRACPA+VV1->VV1_CHAINT ))
			
			nValFre := VVG->VVG_VALFRE
			
			cChavSC9 := cNumPed+"01"
			nCustoVeiculo := 0
			If SB2->B2_QATU > 0
				nCustoVeiculo := SB2->B2_CM1
			endif
			dbSelectArea("SC9")
			dbSetOrder(1)
			If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
				nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
			Endif
			if !SB2->(EOF())
				If SB2->B2_QATU > 0    
					reclock("SB2",.f.)
					SB2->B2_CM1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
					SB2->B2_CM2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
					SB2->B2_CM3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
					SB2->B2_CM4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
					SB2->B2_CM5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
					SB2->B2_VATU1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
					SB2->B2_VATU2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
					SB2->B2_VATU3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
					SB2->B2_VATU4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
					SB2->B2_VATU5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
					msunlock()
				Else
					reclock("SB2",.f.)
					SB2->B2_CM1 := 0
					SB2->B2_CM2 := 0
					SB2->B2_CM3 := 0
					SB2->B2_CM4 := 0
					SB2->B2_CM5 := 0
					SB2->B2_VATU1 := 0
					SB2->B2_VATU2 := 0
					SB2->B2_VATU3 := 0
					SB2->B2_VATU4 := 0
					SB2->B2_VATU5 := 0
					msunlock()
				Endif
			endif
			VVA->(dbSetOrder(1))
			VVA->(dbSeek(xFilial("VVA")+M->VV0_NUMTRA))
			VV1->(dbSetOrder(1))
			VV1->(dbSeek(xFilial("VV1")+M->VV0_CHAINT))
			
			If cTipFat == "2" // Faturamento Direto
				VV0->VV0_DPGFAB := M->VV0_DPGFAB
				If VV0->VV0_VALNEG == 0
					VV0->VV0_VALNEG := M->VV0_VALVDA
				Endif
			Else
				VV0->VV0_VALNEG := VV0->VV0_VALMOV
			Endif
			If VV0->VV0_OPEMOV == "0" .and. cTipFat == "2"	// Faturamento Direto
				VV0->VV0_NUMNFI := "FATDIR"
				VV0->VV0_DPGFAB := M->VV0_DPGFAB
				If VV0->VV0_VALNEG == 0
					VV0->VV0_VALNEG := M->VV0_VALVDA
				Endif
			Else
				VV0->VV0_VALNEG := VV0->VV0_VALMOV
			Endif
			
			if cEstoque == "S" .or. cTipFat $ "24"
				RecLock("VVA",.f.)
				VVA->VVA_CHASSI := M->VV0_CHASSI
				VVA->VVA_CHAINT := M->VV0_CHAINT
				MsUnlock()
			Endif
			dbSelectArea(1)
			SC9->(dbSeek(xFilial("SC9")+cChavSC9))
			While !Eof() .and. SC9->C9_FILIAL == xFilial("SC9") .and. SC9->C9_PEDIDO == cNumPed
				
				If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
					
					cPagto := RetCondVei()
					dbSelectArea("SC9")
					FG_Seek("SB1","SC9->C9_PRODUTO",1)
					FG_Seek("SC5","SC9->C9_PEDIDO",1,.F.)
					FG_Seek("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
					FG_Seek("SB5","SB1->B1_COD")
					FG_Seek("SB2","SB1->B1_COD+cLocVei")
					FG_Seek("SF4","M->VVA_CODTES")
					FG_Seek("SE4","cPagto",1)  //Tem que ser Tipo A para nao criar E1 automatico
					
					aAdd(aPvlNfs,{C9_PEDIDO,;
					C9_ITEM,;
					C9_SEQUEN,;
					C9_QTDLIB,;
					C9_PRCVEN,;
					C9_PRODUTO,;
					SF4->F4_ISS=="S",;
					SC9->(RecNo()),;
					SC5->(RecNo()),;
					SC6->(RecNo()),;
					SE4->(RecNo()),;
					SB1->(RecNo()),;
					SB2->(RecNo()),;
					SF4->(RecNo())})
				Endif
				dbSelectArea("SC9")
				dbSkip()
			Enddo
			
			if Len(aPvlNfs) == 0
				MsgInfo(OemToAnsi(STR0261),OemToAnsi(STR0015))  //"Problema com liberacao para venda..."
				lMsErroAuto := .t.
				DisarmTransaction()
				Break
			Endif
			
			//Funcao que trata aliquota do ICMS para veiculos
			FS_ALIICMS(SB1->B1_COD)
			
			PERGUNTE("MT461A",.f.)
			cNota   := MaPvlNfs(aPvlNfs,cSerie, .F., .F., .f., .T., .F., 0, 0, .T., .F.)
			cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
			
			if lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			Endif
			
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			if SC5->(dbSeek(xFilial("SC5")+M->VV0_NUMPED))
				RecLock("SC5",.f.)
				SC5->C5_CONDPAG := M->VV0_FORPAG
				MsUnlock()
			Endif
			
			dbSelectArea("SF2")
			RecLock("SF2",.f.)
			//SF2->F2_DOC     := cNota
			//SF2->F2_SERIE   := cSerie
			SF2->F2_COND    := cTipPag
			if VE4->VE4_GTPRFT  == "0" // Gera titulo na Proposta
				SF2->F2_DUPL := Right(VV0->VV0_NUMTRA,9)
			Else
				SF2->F2_DUPL := cNota
			Endif
			SF2->F2_PREFORI := cPrefix
			SF2->F2_VALFAT  := nTotEnt
			//SF2->F2_VALICM  := (M->VVA_ALIICM * SF2->F2_BASEICM)/100
			MsUnlock()
			
			//dbSelectArea("SD2")
			//RecLock("SD2",.f.)
			//SD2->D2_PICM    := M->VVA_ALIICM
			//SD2->D2_VALICM  := (M->VVA_ALIICM * SD2->D2_BASEICM)/100
			//MsUnlock()
			
			//dbSelectArea("SF3")
			//RecLock("SF3",.f.)
			//SF3->F3_ALIQICM := M->VVA_ALIICM
			//SF3->F3_VALICM  := (M->VVA_ALIICM * SF3->F3_BASEICM)/100
			//MsUnlock()
			
			if cTipSai == "3" //Remessa
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				cIdeSB6 := space(6)
				if dbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA)
					cIdeSB6 := SD2->D2_IDENTB6
				Endif
				
				//Posicionamento p/ calcular o Custo do Veiculo
				//VV1->(dbSeek(xFilial("VV1")+M->VV0_CHAINT))
				// VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
				//VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
				
				//VVF->(dbSetOrder(1))
				//VVF->(dbSeek(xFilial("VVF")+VV1->VV1_TRACPA ))
				//VVG->(dbSetOrder(1))
				// VVG->(dbSeek(xFilial("VVG")+VVF->VVF_TRACPA+VV1->VV1_CHAINT ))
				
				dbSelectArea("VVF")
				For nCntFor := 1 TO FCount()
					M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
				Next
				
				dbSelectArea("VVG")
				For nCntFor := 1 TO FCount()
					M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
				Next
				
				nCustoVeiculo := 0
				if VV1->VV1_ESTVEI == "0" //Novo
					dbSelectArea("VVG")
					If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
						nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
					ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
						nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
					Endif
				Else
					cFor := GetMv("MV_VUCCTB")
					if !Empty(cFor)
						nCustoVeiculo := FG_FORMULA(cFor)
					Endif
				Endif
				if nCustoVeiculo <= 0
					nCustoVeiculo := VVG->VVG_VCNVEI
				Endif
				
				dbSelectArea("VVD")
				dbSetOrder(1)
				if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
					while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
						if VVD->VVD_ATUCUS=="1"
							nCustoVeiculo += VVD->VVD_VALOR
						Endif
						dbSelectArea("VVD")
						dbSkip()
					Enddo
				Endif
				
				dbSelectArea("SB2")
				dbSetOrder(1)
				if dbSeek(xFilial("SB2")+SD1->D1_COD+cLocVei)
					RecLock("SB2",.f.)
					SB2->B2_CM1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
					SB2->B2_CM2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
					SB2->B2_CM3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
					SB2->B2_CM4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
					SB2->B2_CM5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
					
					SB2->B2_VATU1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
					SB2->B2_VATU2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
					SB2->B2_VATU3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
					SB2->B2_VATU4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
					SB2->B2_VATU5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
					MsUnlock()
				Endif
				
				dbSelectArea("SB6")
				dbSetOrder(3)
				if dbSeek(xFilial("SB6")+cIdeSB6+SB1->B1_COD)
					RecLock("SB6",.f.)
					SB6->B6_CUSTO1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
					SB6->B6_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
					SB6->B6_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
					SB6->B6_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
					SB6->B6_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
					MsUnlock()
				Endif
				
				dbSelectArea("SD2")
				dbSetOrder(3)
				If dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
					RecLock("SD2",.f.)
					SD2->D2_CUSTO1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
					SD2->D2_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
					SD2->D2_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
					SD2->D2_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
					SD2->D2_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
					MsUnlock()
				EndIf
				
				/*Grava valores de PIS e Cofins no SD2 */
				FG_Seek("SB1","SD2->D2_COD",1)
				FG_Seek("SF4","SD2->D2_TES")
				
				If cTipFat == "2" //Faturamento Direto
					aPisCof := CalcPiscofSai(VVA->VVA_VALCVD)
					GrvPisCof(VVA->VVA_VALCVD,aPiscof,"S")
				Else
					if cTipFat == "1" // Veiculo Usado
						Reclock("SB1",.F.)
						SB1->B1_PPIS := 0.65
						MsUnlock("SB1")
						aPisCof := CalcPiscofSai((VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)))
						GrvPisCof((VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)),aPiscof,"S")
					Endif
					if cTipSai == "3" //Remessa
						aPisCof := CalcPiscofSai(0)
						GrvPisCof((VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)),aPiscof,"S")
					EndIF
				ENDIF
				/*----------------------------------------*/
				
			Endif
			
		Endif
		
		dbSelectArea("SC9")
		dbSetOrder(1)
		if cTipFat == "2" // Fat. Direto
			dbSeek(xFilial("SA1")+M->VV0_CLIFTD+M->VV0_LOJFTD)
		Else
			if cTipSai == "0" // Venda/Simulacao
				dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA)
			Endif
		Endif
		if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") .and. cTipSai # "3"
			FS_GRCDPG10()
		Endif
	Else
		IncProc(OemToAnsi(STR0262))  //Atualizando Dados...
	EndIf
Endif

if lJaGrv .and. cTip == "S"
	Return(.t.)
Endif

if Inclui
	lRetRec := .t.
Else
	lRetRec := .f.
Endif

//Gravacao do VV0

If cTip == "S"
	
	IncProc(STR0230)  // Atualizando Base de Dados
	
	If lAbortPrint
		If MsgYesNo(OemToAnsi(STR0231),OemToAnsi(STR0199))
			Help("  ",1,"M160PROABO")
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .F.
		EndIf
	EndIf
	
	if cParPrg == "1" //Simulacao
		if Empty(M->VV0_OPEMOV) .or. !M->VV0_OPEMOV $ "234"    //Transferencia / Remessa / Devolucao
			if cEstoque == "S"
				M->VV0_OPEMOV := "1" //Simulacao
			Else
				M->VV0_OPEMOV := "5" //Simulacao Nao Estoque
			Endif
		Endif
	Endif
	
	dbSelectArea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+cNumTra)
	RecLock("VV0",lRetRec)
	VV0->VV0_FILIAL := xFilial("VV0")
	VV0->VV0_NUMTRA := M->VV0_NUMTRA
	VV0->VV0_OPEMOV := M->VV0_OPEMOV
	VV0->VV0_DATMOV := dDatMov
	VV0->VV0_TIPFAT := cTipFat
	VV0->VV0_DATEMI := M->VV0_DATEMI
	VV0->VV0_CODCLI := M->VV0_CODCLI
	VV0->VV0_LOJA   := M->VV0_LOJA
	VV0->VV0_ESTCLI := cEstCli
	VV0->VV0_CODAVA := M->VV0_CODAVA
	VV0->VV0_LOJAAV := M->VV0_LOJAAV
	VV0->VV0_CLIALI := M->VV0_CLIALI
	VV0->VV0_LOJALI := M->VV0_LOJALI
	VV0->VV0_CLIFTD := M->VV0_CLIFTD
	VV0->VV0_LOJFTD := M->VV0_LOJFTD
	VV0->VV0_AGEFIN := M->VV0_AGEFIN
	VV0->VV0_CODVEN := M->VV0_CODVEN
	VV0->VV0_TIPVEN := M->VV0_TIPVEN
	VV0->VV0_CATVEN := M->VV0_CATVEN
	VV0->VV0_FORPAG := M->VV0_FORPAG
	VV0->VV0_VCARCR := M->VV0_VCARCR
	VV0->VV0_EMPCON := M->VV0_EMPCON
	VV0->VV0_CODGRU := M->VV0_CODGRU
	VV0->VV0_NUMCOT := M->VV0_NUMCOT
	VV0->VV0_VALMOV := M->VV0_VALMOV
	If VV0->VV0_VALTOT == 0
		VV0->VV0_VALTOT := M->VV0_VALTOT
	EndIf
	VV0->VV0_DESACE := M->VV0_DESACE
	VV0->VV0_VALDES := M->VV0_VALDES
	VV0->VV0_VBAICM := M->VVA_VBAICM
    Iif(!FM_PILHA("VEIVM017"),	VV0->VV0_ALIICM := M->VVA_ALIICM , VV0->VV0_ALIICM := M->VV0_ALIICM )  //FNC - 28020/2010 - BOBY - 16/12/10
	VV0->VV0_TOTICM := M->VVA_ICMVEN
	VV0->VV0_CODBCO := M->VV0_CODBCO
	VV0->VV0_CODAGE := M->VV0_CODAGE
	VV0->VV0_NUMLIB := cNumLib
	VV0->VV0_SITNFI := "1" // Valida
	VV0->VV0_AUTFAT := M->VV0_AUTFAT
	VV0->VV0_DTHEMI := Dtoc(dDataBase) + [/] + Time()
	If cTipFat == "2" // Faturamento Direto
		VV0->VV0_MODVDA := M->VV0_MODVDA
		VV0->VV0_DPGFAB := M->VV0_DPGFAB
		If VV0->VV0_VALNEG == 0
			VV0->VV0_VALNEG := M->VVA_VALVDA
		Endif
	Else
		if VV1->VV1_SITVEI == "4" //Consignado
			VV0->VV0_MODVDA := "4"
		Else
			VV0->VV0_MODVDA := VV1->VV1_ESTVEI
		Endif
		VV0->VV0_VALNEG := VV0->VV0_VALMOV
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 31/07/2009                                              ³
	//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
	//³FNC 18018/2009                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VV0->VV0_TPFRET := M->VV0_TPFRET
	MsUnlock()
Elseif cTip == "D"  // D - Deletar
	RollBackSx8("VV0")
	if !RecLock("VV0",.f.,.t.)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	Endif
	DbDelete()
	MsUnlock()
	WriteSx2("VV0")
Elseif cTip == "G"
	// Confirma Gravacao
	if !RecLock("VV0",.f.)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	Endif
	VV0->VV0_OPEMOV := M->VV0_OPEMOV
	VV0->VV0_NUMLIB := M->VV0_NUMLIB
	VV0->VV0_CODBCO := M->VV0_CODBCO
	VV0->VV0_CODAGE := M->VV0_CODAGE
	VV0->VV0_SITNFI := "1" // Valida
	VV0->VV0_CODTRA := M->VV0_CODTRA
	if cParPrg == "2" .or. M->VV0_OPEMOV $ "2346"    //Transferencia/Remessa/Devolucao
		VV0->VV0_NUMPED := M->VV0_NUMPED
		VV0->VV0_NNFFDI := M->VV0_NNFFDI
		VV0->VV0_SNFFDI := M->VV0_SNFFDI
		if FieldPos('VV0_SDOCFD') > 0
			VV0->VV0_SDOCFD := FGX_UFSNF( M->VV0_SNFFDI )
		EndIf
		VV0->VV0_CRECON := M->VV0_CRECON
		//		M->VV0_SEQVIS   := Right(VV0->VV0_NUMTRA,6)
		//		VV0->VV0_SEQVIS := M->VV0_SEQVIS
	Endif
	if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") .or. M->VV0_OPEMOV $ "2346"    //Transferencia/Remessa/Devolucao
		VV0->VV0_NUMNFI := cNota
		VV0->VV0_SERNFI := cSerie // INFO: A serie vem da integracao mapvlnfs entao deve estar correto embora acho que aqui nao tenhamos o SF2 posicionado
		VV0->VV0_DATMOV := ddatabase
		VV0->VV0_CRECON := M->VV0_CRECON
		//		M->VV0_SEQVIS   := Right(VV0->VV0_NUMTRA,6)
		//		VV0->VV0_SEQVIS := M->VV0_SEQVIS
	Endif
	VV0->VV0_DTHEMI := Dtoc(dDataBase) + [/] + Time()
	if cTipSai $ "46"  //Devolucao
		VV0->VV0_TRADEV := VVF->VVF_TRACPA
	Endif
	
	If VV0->VV0_OPEMOV == "0" .and. cTipFat == "2"	// Faturamento Direto
		VV0->VV0_NUMNFI := "FATDIR"
		VV0->VV0_MODVDA := M->VV0_MODVDA
		VV0->VV0_DPGFAB := M->VV0_DPGFAB
		If VV0->VV0_VALNEG == 0
			VV0->VV0_VALNEG := M->VVA_VALVDA
		Endif
	Else
		if VV1->VV1_SITVEI == "4" //Consignado
			VV0->VV0_MODVDA := "4"
		Else
			VV0->VV0_MODVDA := VV1->VV1_ESTVEI
		Endif
		VV0->VV0_VALNEG := VV0->VV0_VALMOV
	Endif
	
	MsUnlock()
	
	If cTipSai $ "46" .AND. !( FunName() $ "VEIVM015.VEIVM017" ) // Devolucao
		dbSelectArea("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_SITNFI := "2" // Devolvida
		VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
	Endif
	

Endif

//Gravacao do VVA

VVA->(dbSeek(xFilial("VVA")+M->VV0_NUMTRA))
VV1->(dbSeek(xFilial("VV1")+M->VV0_CHAINT))

If cTip == "S"
	RecLock("VVA",lRetRec)
	VVA->VVA_SIMVDA := if(M->VV0_OPEMOV=="1","S","V") // if(Inclui,cSimVda,VVA->VVA_SIMVDA)
	VVA->VVA_FILIAL := xFilial("VVA")
	VVA->VVA_NUMTRA := M->VV0_NUMTRA
	VVA->VVA_CODIND := M->VVA_CODIND
	VVA->VVA_DATRCU := M->VVA_DATRCU
	VVA->VVA_DATRTC := M->VVA_DATRTC
	VVA->VVA_DATBFB := M->VVA_DATBFB
	VVA->VVA_DATDCL := M->VVA_DATDCL
	VVA->VVA_VCAVEI := M->VVA_VCAVEI
	
	if cEstoque == "S" .or. cTipFat $ "24"
		VVA->VVA_CHASSI := M->VVA_CHASSI
		VVA->VVA_CHAINT := M->VVA_CHAINT
	Endif
	if cEstoque == "S"
		VVA->VVA_VMFVEI := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VCAVEI} })
		VVA->VVA_JUREST := M->VVA_JUREST
		VVA->VVA_JMFEST := FG_CalcMF({ {dDataBase,M->VVA_JUREST} })
	Else
		VVA->VVA_VMFVEI := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VCAVEI} }) + FG_CalcMF({ {M->VV0_DATMOV,nValCor} })
		VVA->VVA_JUREST := 0
		VVA->VVA_JMFEST := 0
	Endif
	
	VVA->VVA_CODTES := M->VVA_CODTES
	VVA->VVA_VALDES := M->VVA_VALDES
	VVA->VVA_PERDES := M->VVA_PERDES
	VVA->VVA_VBAICM := M->VVA_VBAICM
	
	cChave := cGruVei+M->VVA_CHAINT
	FG_SEEK("SB1","cChave",7,.f.)
	
	FG_SEEK("SF4","VVA->VVA_CODTES",1,.f.)
	
	if cTipSai == "0" // Venda/Simulacao
		
		VVA->VVA_ACESSO := M->VVA_ACESSO
		VVA->VVA_AMFSSO := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_ACESSO} })
		
		if SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG)) .and. Empty(aIteParc[1,1]) .and. !lTroca
			
			if val(AllTrim(SE4->E4_COND)) > 0 .and. M->VV0_TIPFAT # "2"
				FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,"VV0_FORPAG",nTotEnt)
			Else
				FG_DesfPag()
				cCondic1:=ctod(" ")
				cCondic2:=space(02)
				cCondic3:=space(02)
				cCondic4:=space(02)
			Endif
			
		Endif
		
	Endif
	dbSelectArea("VVA")
	VVA->VVA_VALMOV := M->VV0_VALMOV
	VVA->VVA_VMFMOV :=  FG_CalcMF(FG_RetVdCp(,,"S",nTotEnt))
	if VVA->VVA_VMFMOV == 0
		VVA->VVA_VMFMOV := FG_CalcMF({ {dDataBase,M->VVA_VALMOV} })
	Endif
	
	If cTipFat == "2" //Faturamento Direto
		aPisCof := CalcPiscofSai(M->VVA_VALCVD)
		VVA->VVA_VALVDA := M->VVA_VALVDA
		VVA->VVA_VMFVDA := VVA->VVA_VMFMOV
		VVA->VVA_VALCVD := M->VVA_VALCVD
		nValBasCom      := M->VVA_VALCVD
		VVA->VVA_VMFCVD := VVA->VVA_VMFMOV
		VVA->VVA_ISSCVD := M->VVA_ISSCVD
		VVA->VVA_IMFCVD := FG_CalcMF( { {FG_RtDtImp("ISS",M->VV0_DATMOV),M->VVA_ISSCVD} })
		VVA->VVA_PISVEN := aPisCof[1,1] //M->VVA_VALCVD * nAliPis
		VVA->VVA_PMFVEN := FG_CalcMF( { {FG_RtDtImp("PIS",M->VV0_DATMOV),aPisCof[1,1]} })
		VVA->VVA_COFVEN := aPisCof[1,2] //M->VVA_VALCVD * nAliCof
		VVA->VVA_CMFVEN := FG_CalcMF( { {FG_RtDtImp("COF",M->VV0_DATMOV),aPisCof[1,2]} })
	Else
		VVA->VVA_VALVDA := M->VVA_VALVDA
		nValBasCom      := M->VVA_VALVDA
		VVA->VVA_VMFVDA := VVA->VVA_VMFMOV - M->VVA_AMFSSO
		VVA->VVA_ICMVEN := M->VVA_ICMVEN
		VVA->VVA_IMFVEN := FG_CalcMF( { {FG_RtDtImp("ICM",M->VV0_DATMOV),M->VVA_ICMVEN} })
		VVA->VVA_INPICO := M->VVA_INPICO
		
		if cTipFat == "1" // Veiculo Usado
			aPisCof := CalcPiscofSai((M->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)))
			M->VVA_PISVEN := aPisCof[1,1] //(M->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)) * nAliPis
			M->VVA_COFVEN := aPisCof[1,2] //(M->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)) * nAliCof
			M->VVA_PMFVEN := FG_CalcMF( { {FG_RtDtImp("PIS",M->VV0_DATMOV),M->VVA_PISVEN }})
			M->VVA_CMFVEN := FG_CalcMF( { {FG_RtDtImp("COF",M->VV0_DATMOV),M->VVA_COFVEN }})
		Endif
		
		if cTipSai == "3" //Remessa
			dbSelectArea("VVG")
			dbSetOrder(1)
			if dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)
				M->VVA_PISENT := VVG->VVG_PISENT
				M->VVA_COFENT := VVG->VVG_COFENT
			Endif
			dbSelectArea("VVA")
			M->VVA_PISVEN := 0
			M->VVA_COFVEN := 0
			M->VVA_PMFVEN := 0
			M->VVA_CMFVEN := 0
			VVA->VVA_PISENT := M->VVA_PISENT
			VVA->VVA_PMFENT := FG_CalcMF( { {FG_RtDtImp("PIS",VVF->VVF_DATMOV),VVA->VVA_PISENT} })
			VVA->VVA_COFENT := M->VVA_COFENT
			VVA->VVA_CMFENT := FG_CalcMF( { {FG_RtDtImp("COF",VVF->VVF_DATMOV),VVA->VVA_COFENT} })
		Endif
		
		VVA->VVA_PISVEN := M->VVA_PISVEN
		VVA->VVA_COFVEN := M->VVA_COFVEN
		VVA->VVA_PMFVEN := M->VVA_PMFVEN
		VVA->VVA_CMFVEN := M->VVA_CMFVEN
		
	Endif
	
	if cEstoque == "S" .or. cTipFat $ "24"
		M->VVA_TRACPA := VV1->VV1_TRACPA
	Else
		M->VVA_TRACPA := VVG->VVG_TRACPA
	Endif
	If M->VV0_OPEMOV == "0" .and. cTipFat == "2"
		M->VVA_TRACPA := "FATDIR"
	Endif
	
	if cTipSai $ "03"   // Venda / Simulacao
		aAdd(aVetTra,{VV0->VV0_CODVEN,1})
		If VV0->VV0_OPEMOV == "0" // So Cria Comissao (VSG) se for uma Venda
			
		If FunName() $ "VEIVM011.VEIVMM01"
				If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
					ExecBlock("FS_COMVEI",.f.,.f.)
					VVA->VVA_COMVDE := M->VVA_COMVDE
					ExecBlock("FS_COMVEI",.f.,.f.)
					VVA->VVA_COMGER := M->VVA_COMGER
					VVA->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMVDE}} )
					VVA->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMGER}} )
				Else
					aValCom    := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValBasCom,"T")
					VVA->VVA_COMVDE := aValCom[1]
					VVA->VVA_COMGER := aValCom[2]
					aValCom    := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValBasCom,"D")
					VVA->VVA_CMFVDE := FG_CalcMF(  aValCom[1] )
					VVA->VVA_CMFGER := FG_CalcMF(  aValCom[2] )
				Endif
			Endif
		Endif
		VVA->VVA_INPCRT := M->VVA_INPCRT
		VVA->VVA_INISRT := M->VVA_INISRT
		aPisCof := CalcPisCofSai(M->VVA_RECTEC)
		if M->VVA_INPCRT == "1"
			VVA->VVA_PISRTE   := aPisCof[1,1] + aPisCof[1,2] //FG_PARSIS("COF",dDataBase,M->VVA_RECTEC) + FG_PARSIS("PIS",dDataBase,M->VVA_RECTEC) // M->VVA_PISRTE // nPiCoRt
			VVA->VVA_PMFRTE   := FG_CalcMF({ {FG_RtDtImp("PIS",M->VVA_DATRTC),M->VVA_PISRTE} }) //FG_PARSIS("COF",dDataBase,M->VVA_RECTEC) + FG_PARSIS("PIS",dDataBase,M->VVA_RECTEC) // M->VVA_PISRTE // nPiCoRt
		Endif
		if M->VVA_INISRT == "1"
			VVA->VVA_ISSRTE   := M->VVA_RECTEC * nAliIss // FG_PARSIS("ISS",dDataBase,M->VVA_RECTEC) // nIssRt
			VVA->VVA_IMFRTE   := FG_CalcMF({ {FG_RtDtImp("ISS",M->VVA_DATRTC),M->VVA_RECTEC * nAliIss} }) // FG_PARSIS("ISS",dDataBase,M->VVA_RECTEC) // nIssRt
		Endif
	Endif
	
	VVA->VVA_ALIICM := M->VVA_ALIICM
	
	if cEstoque == "S" .or. cTipFat $ "24"
		VVA->VVA_TRACPA := VV1->VV1_TRACPA
		VVA->VVA_ESTVEI := VV1->VV1_ESTVEI
		VVA->VVA_CODORI := VV1->VV1_CODORI
		VVA->VVA_ICMCOM := VVG->VVG_ICMCOM
		VVA->VVA_VDESCO := VVG->VVG_VDESCO
		VVA->VVA_VMFSCO := FG_CalcMF({ {VVF->VVF_DATMOV,VVA->VVA_VDESCO} })
		VVA->VVA_IMFCOM := FG_CalcMF( { {FG_RtDtImp("ICM",VVF->VVF_DATMOV),VVA->VVA_ICMCOM} })
		VVA->VVA_PISENT := M->VVA_PISENT
		VVA->VVA_PMFENT := FG_CalcMF( { {FG_RtDtImp("PIS",VVF->VVF_DATMOV),VVA->VVA_PISENT} })
		VVA->VVA_COFENT := M->VVA_COFENT
		VVA->VVA_CMFENT := FG_CalcMF( { {FG_RtDtImp("COF",VVF->VVF_DATMOV),VVA->VVA_COFENT} })
		VVA->VVA_EMINVD := M->VVA_EMINVD
		VVA->VVA_COMPGC := 0
		// Por Enquanto nao tera controle da Comissao de Cota e Contemplacao
		VVA->VVA_COMCOT := 0 //FG_COMISS("VC") // Comissao s/ Cota de Consorcio
		VVA->VVA_CMFCOT := 0 //FG_COMISS("VC") // Comissao s/ Cota de Consorcio
		VVA->VVA_COMCTP := 0 //FG_COMISS("VT") // Comissao s/ Contemplacao do Consorcio
		VVA->VVA_CMFCTP := 0 //FG_COMISS("VT") // Comissao s/ Contemplacao do Consorcio
		VVA->VVA_SEGVIA := M->VVA_SEGVIA
		VVA->VVA_SMFVIA := FG_CalcMF({ {FG_RtDtCV("SGV","",M->VV0_DATMOV),M->VVA_SEGVIA} })
		VVA->VVA_VALASS := M->VVA_VALASS
		VVA->VVA_VMFASS := FG_CalcMF({ {FG_RtDtCV("ASS","",M->VV0_DATMOV),M->VVA_VALASS} })
		VVA->VVA_VALFRE := M->VVA_VALFRE
		if cTipFat == "2"
			VVA->VVA_VMFFRE := FG_CalcMF({ {FG_RtDtCV("FVD","",M->VV0_DATMOV),M->VVA_VALFRE} })
		Else
			VVA->VVA_VMFFRE := FG_CalcMF({ {FG_RtDtCV("FVD","",VVF->VVF_DATMOV),M->VVA_VALFRE} })
		Endif
		VVA->VVA_ASSIMP := M->VVA_ASSIMP
		VVA->VVA_AMFIMP := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_ASSIMP} })
		VVA->VVA_VALREV := M->VVA_VALREV
		VVA->VVA_VMFREV := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VALREV} })
		VVA->VVA_DESFIX := M->VVA_DESFIX
		VVA->VVA_DMFFIX := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_DESFIX} })
		VVA->VVA_DSPFIN := M->VVA_DSPFIN
		VVA->VVA_DMFFIN := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_DSPFIN} })
		VVA->VVA_COMPAT := 0 //Comissao de Patio
		VVA->VVA_CMFPAT := 0 //Comissao de Patio Moeda Forte
	Else
		VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
		VVA->VVA_CHAINT := M->VV1_CORVEI
		VVA->VVA_TRACPA := Alltrim(Str(VV2->(RECNO())))
	Endif
	VVA->VVA_BONFAB := M->VVA_BONFAB
	VVA->VVA_BMFFAB := FG_CalcMF({ {M->VVA_DATBFB,M->VVA_BONFAB} })
	VVA->VVA_INPCBF := M->VVA_INPCBF
	VVA->VVA_INISBF := M->VVA_INISBF
	If M->VVA_INPCBF == "1"
		aPisCof := CalcPisCofSai(M->VVA_BONFAB)
		VVA->VVA_PISBFB := aPisCof[1,1] + aPisCof[1,2] //(M->VVA_BONFAB * nAliPis) + (M->VVA_BONFAB * nAliCof)
		VVA->VVA_PMFBFB := FG_CalcMF({ {FG_RtDtImp("PIS",M->VVA_DATBFB),M->VVA_PISBFB} })
	Endif
	If M->VVA_INISBF == "1"
		VVA->VVA_ISSBFB   := M->VVA_BONFAB * nAliIss
		VVA->VVA_IMFBFB   := FG_CalcMF({ {FG_RtDtImp("ISS",M->VVA_DATBFB),M->VVA_BONFAB * nAliIss} })
	Endif
	VVA->VVA_REDCUS := M->VVA_REDCUS
	VVA->VVA_RMFCUS := FG_CalcMF({ {M->VVA_DATRCU,M->VVA_REDCUS} })
	VVA->VVA_DESCLI := M->VVA_DESCLI
	VVA->VVA_DMFCLI := FG_CalcMF({ {M->VVA_DATDCL,M->VVA_DESCLI} })
	VVA->VVA_RECTEC := M->VVA_RECTEC
	VVA->VVA_RMFTEC := FG_CalcMF({ {M->VVA_DATRTC,M->VVA_RECTEC} })
	VVA->VVA_DESVEI := M->VVA_DESVEI//FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT)
	VVA->VVA_DMFVEI := FG_CalcMF({ { M->VV0_DATMOV,M->VVA_DESVEI} })//FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT)
	VVA->VVA_RECVEI := M->VVA_RECVEI
	VVA->VVA_RMFVEI := FG_CalcMF({ { M->VV0_DATMOV,M->VVA_RECVEI} })//FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT)
	If cTipFat == "2" // Faturamento Direto
		VVA->VVA_VCAVEI := 0
		VVA->VVA_VMFVEI := 0
		VVA->VVA_JUREST := 0
		VVA->VVA_JMFEST := 0
		VVA->VVA_ALIPIC := M->VVA_ALIPIC
		VVA->VVA_ALIIPI := M->VVA_ALIIPI
		VVA->VVA_VRENET := M->VVA_VRENET
		VVA->VVA_PERCVD := M->VVA_PERCVD
		VVA->VVA_FATTOT := VVA->VVA_VALCVD+VVA->VVA_COMCOT+VVA->VVA_COMCTP+VVA->VVA_RECTEC+VVA->VVA_BONFAB
		VVA->VVA_FMFTOT := VVA->VVA_VMFCVD+VVA->VVA_CMFCOT+VVA->VVA_CMFCTP+VVA->VVA_RMFTEC+VVA->VVA_BMFFAB
	Else
		VVA->VVA_FATTOT := VVA->VVA_VALMOV+VVA->VVA_COMCOT+VVA->VVA_COMCTP+VVA->VVA_RECTEC+VVA->VVA_BONFAB
		VVA->VVA_FMFTOT := VVA->VVA_VMFMOV+VVA->VVA_CMFCOT+VVA->VVA_CMFCTP+VVA->VVA_RMFTEC+VVA->VVA_BMFFAB
	Endif
	
	VVA->VVA_TOTIMP := VVA->VVA_ICMVEN+VVA->VVA_ISSCVD+VVA->VVA_PISVEN+VVA->VVA_COFVEN+VVA->VVA_ISSRTE+VVA->VVA_PISRTE+VVA->VVA_ISSBFB+VVA->VVA_PISBFB
	VVA->VVA_TMFIMP := VVA->VVA_IMFVEN+VVA->VVA_IMFCVD+VVA->VVA_PMFVEN+VVA->VVA_CMFVEN+VVA->VVA_IMFRTE+VVA->VVA_PMFRTE+VVA->VVA_IMFBFB+VVA->VVA_PMFBFB
	
	if cTipFat == "2"
		VVA->VVA_TOTCUS := FG_FORMULA(GetNewPar("MV_TOTCUFD","VVA->VVA_VCAVEI-VVA->VVA_REDCUS+VVA->VVA_JUREST+VVA->VVA_ACESSO+VVA->VVA_VDESCO+VVA->VVA_PISENT+VVA->VVA_COFENT"))
		VVA->VVA_TMFCUS := FG_FORMULA(GetNewPar("MV_TMFCUFD","VVA->VVA_VMFVEI-VVA->VVA_RMFCUS+VVA->VVA_JMFEST+VVA->VVA_AMFSSO+VVA->VVA_VMFSCO+VVA->VVA_PMFENT+VVA->VVA_CMFENT"))
	Else
		VVA->VVA_TOTCUS := FG_FORMULA(GetNewPar("MV_TOTCUFN","VVA->VVA_VCAVEI-VVA->VVA_REDCUS+VVA->VVA_JUREST+VVA->VVA_VALFRE+VVA->VVA_ACESSO+VVA->VVA_VDESCO+VVA->VVA_PISENT+VVA->VVA_COFENT"))
		VVA->VVA_TMFCUS := FG_FORMULA(GetNewPar("MV_TMFCUFN","VVA->VVA_VMFVEI-VVA->VVA_RMFCUS+VVA->VVA_JMFEST+VVA->VVA_VMFFRE+VVA->VVA_AMFSSO+VVA->VVA_VMFSCO+VVA->VVA_PMFENT+VVA->VVA_CMFENT"))
	Endif
	
	//Antigo
	//VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_TOTIMP-VVA->VVA_TOTCUS
	//VVA->VVA_LMFBRU := VVA->VVA_FMFTOT-VVA->VVA_TMFIMP-VVA->VVA_TMFCUS
	
	VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_TOTIMP-VVA->VVA_VCAVEI-VVA->VVA_VALFRE
	VVA->VVA_LMFBRU := VVA->VVA_FMFTOT-VVA->VVA_TMFIMP-VVA->VVA_VMFVEI-VVA->VVA_VMFFRE
	
	if cTipFat == "2"
		VVA->VVA_TOTDES := VVA->VVA_DESVEI+VVA->VVA_DESCLI+VVA->VVA_SEGVIA+VVA->VVA_VALASS+VVA->VVA_VALREV+VVA->VVA_VALFRE+VVA->VVA_ASSIMP+VVA->VVA_DESFIX
		VVA->VVA_TMFDES := VVA->VVA_DMFVEI+VVA->VVA_DMFCLI+VVA->VVA_SMFVIA+VVA->VVA_VMFASS+VVA->VVA_VMFREV+VVA->VVA_VMFFRE+VVA->VVA_AMFIMP+VVA->VVA_DMFFIX
	Else
		VVA->VVA_TOTDES := VVA->VVA_DESVEI+VVA->VVA_DESCLI+VVA->VVA_SEGVIA+VVA->VVA_VALASS+VVA->VVA_VALREV+VVA->VVA_ASSIMP+VVA->VVA_DESFIX
		VVA->VVA_TMFDES := VVA->VVA_DMFVEI+VVA->VVA_DMFCLI+VVA->VVA_SMFVIA+VVA->VVA_VMFASS+VVA->VVA_VMFREV+VVA->VVA_AMFIMP+VVA->VVA_DMFFIX
	Endif
	
	//Antigo
	//VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_TOTDES+VVA->VVA_RECVEI //LUCRO MARGINAL
	//VVA->VVA_LMFLQ1 := VVA->VVA_LMFBRU-VVA->VVA_TMFDES+VVA->VVA_RMFVEI
	
	VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
	VVA->VVA_LMFLQ1 := VVA->VVA_LMFBRU-VVA->VVA_JMFEST-VVA->VVA_AMFSSO-VVA->VVA_VMFSCO-VVA->VVA_DMFCLI-VVA->VVA_SMFVIA-VVA->VVA_VMFASS-VVA->VVA_VMFREV-VVA->VVA_DMFVEI-VVA->VVA_AMFIMP-VVA->VVA_CMFVDE-VVA->VVA_CMFGER-VVA->VVA_CMFPAT //LUCRO MARGINAL
	
	//Antigo
	//VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_VALIRF-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT
	//VVA->VVA_LMFLQ2 := VVA->VVA_LMFLQ1-VVA->VVA_VMFIRF-VVA->VVA_CMFVDE-VVA->VVA_CMFGER-VVA->VVA_CMFPAT
	
	VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)      //LAIR
	VVA->VVA_LMFLQ2 := VVA->VVA_LMFLQ1-VVA->VVA_DMFFIX+(VVA->VVA_RMFCUS+VVA->VVA_RMFVEI-VVA->VVA_DMFFIN)      //LAIR
	
	If M->VV0_OPEMOV == "0" .or. Inclui // Operacao de Venda ou Inclusao
		VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
	Endif
	dbSelectArea("VVA")
	if !(cTipSai == "4") // Quando nao for Devolucao
		MSMM(,TamSx3("VVA_OBSERV")[1],,cObserv,1,,,"VVA","VVA_OBSMEM")
	Endif
	
	MsUnlock()
	
	if cParPrg $ "12" // Simulacao/Proposta
		// Gravacao dos Dados dos Tipos de Pagamentos digitados na Entrada
		if cTipSai == "0" .and. cTipFat != "2" // Venda/Simulacao - que nao seja Faturamento Direto
			
			VM110DELNEG() // Exclui negociacao anterior
			
			aMemos  := {{"VS9_OBSMEM","VS9_OBSERV"}}
			For i:=1 to len(aColsC)
				if Empty(aColsC[i,1])
					Loop
				Endif
				dbSelectArea("VS9")
				dbSetOrder(1)
				if !aColsC[i,len(aColsC[i])]
					cObserv2 := aColsC[i,FG_POSVAR('VS9_OBSERV',"aHeaderC")]
					RecLock("VS9",.T.)
					FG_GRAVAR("VS9",aColsC,aHeaderC,i)
					VS9->VS9_FILIAL := xFilial("VS9")
					VS9->VS9_NUMIDE := M->VV0_NUMTRA
					VS9->VS9_TIPOPE := "V"
					VS9->VS9_VALPAG := aColsC[i,FG_POSVAR('VS9_VALPAG',"aHeaderC")]
					VS9->VS9_REFPAG := aColsC[i,FG_POSVAR('VS9_REFPAG',"aHeaderC")]
					VS9->VS9_PORTAD := aColsC[i,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
					VS9->VS9_SEQUEN := aColsC[i,FG_POSVAR('VS9_SEQUEN',"aHeaderC")]
					MSMM(,TamSx3("VS9_OBSERV")[1],,cObserv2,1,,,"VS9","VS9_OBSMEM")
					ConfirmSx8()
					MsUnlock()
				Endif
			Next
			
			aMemos  := {{"VVA_OBSMEM","VVA_OBSERV"}}
			
			For i:=1 to Len(aIteParc)
				if Empty(aIteParc[i,1])
					Exit
				Endif
				RecLock("VS9", .T.)
				VS9->VS9_FILIAL := xFilial("VS9")
				VS9->VS9_NUMIDE := M->VV0_NUMTRA
				VS9->VS9_TIPOPE := "V"
				VS9->VS9_TIPPAG := "DP"
//				VS9->VS9_DESPAG := "DUPLICATA"
				VS9->VS9_DATPAG := DataValida(aIteParc[i,1])
				VS9->VS9_VALPAG := aIteParc[i,2]
				VS9->VS9_PORTAD := cCodBco
				if !Empty(cCondic1) .and. !Empty(cCondic3)
					VS9->VS9_REFPAG := alltrim(dtoc(cCondic1))+strzero(val(cCondic2),2)+strzero(val(cCondic3),2)+strzero(val(cCondic4),2)
				Endif
				MsUnlock()
			Next
			
			For i:=1 to len(aGravaEnt)
				dbSelectArea("VSE")
				dbSetOrder(1)
				RecLock("VSE",.T.)
				VSE->VSE_FILIAL := xFilial("VSE")
				VSE->VSE_NUMIDE := M->VV0_NUMTRA
				VSE->VSE_TIPOPE := 'V'
				VSE->VSE_SEQUEN := StrZero(aGravaEnt[i,1],2)
				VSE->VSE_TIPPAG := aGravaEnt[i,2]
				VSE->VSE_DESCCP := aGravaEnt[i,3]
				VSE->VSE_NOMECP := aGravaEnt[i,4]
				VSE->VSE_TIPOCP := aGravaEnt[i,5]
				VSE->VSE_TAMACP := aGravaEnt[i,6]
				VSE->VSE_DECICP := aGravaEnt[i,7]
				VSE->VSE_PICTCP := aGravaEnt[i,8]
				VSE->VSE_VALDIG := aGravaEnt[i,9]
				MsUnlock()
			Next
		Endif
	Endif
	
	if cTipSai == "0"
		//Gravacao dos Acessorios
		FS_GRVACE("VVT")
	Endif
	
	If FunName() == "VEIVM010"
		//FS_AtuVZ7("I") // Inclusao ou Alteracao dos Itens de Campanha
	Endif
	
Elseif cTip == "D" // D - Deletar
	
	dbSelectArea("VVA")
	If dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		RecLock("VVA",.f.,.t.)
		DbDelete()
		MsUnlock()
		WriteSx2("VVA")
		
		dbSelectArea("VSE")
		If dbSeek(xFilial("VSE")+VV0->VV0_NUMTRA+'V')
			while VSE->VSE_FILIAL+VSE->VSE_NUMIDE+VSE->VSE_TIPOPE == xFilial("VSE")+VV0->VV0_NUMTRA+"V" .and. !eof()
				RecLock("VSE",.f.,.t.)
				DbDelete()
				MsUnlock()
				WriteSx2("VSE")
				dbSkip()
			Enddo
		Endif
		
		dbSelectArea("VS9")
		If dbSeek(xFilial("VS9")+VV0->VV0_NUMTRA+'V')
			while VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VV0->VV0_NUMTRA+"V" .and. !eof()
				RecLock("VS9",.f.,.t.)
				DbDelete()
				MsUnlock()
				WriteSx2("VS9")
				dbSkip()
			Enddo
		Endif
	Endif
	
	If FunName() == "VEIVM010"
		//FS_AtuVZ7("D") // Delecao dos Itens de Campanha
	Endif
	
Elseif cTip == "G"
	
	dbSelectarea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	RecLock("VVA",.f.)
	VVA->VVA_SIMVDA := if(M->VV0_OPEMOV=="1","S","V")
	VVA->VVA_ACESSO := M->VVA_ACESSO
	VVA->VVA_AMFSSO := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_ACESSO} })
	If M->VV0_OPEMOV == "0" .or. Inclui .or. (empty(VVA->VVA_USUARI).and.M->VV0_OPEMOV == "1" )// Operacao de Venda ou Inclusao ou (Qdo Usuario vazio e simulacao)
		VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
	Endif
	
	If cTipFat == "2" //Faturamento Direto
		nValBasCom      := VVA->VVA_VALCVD
	Else
		nValBasCom      := VVA->VVA_VALVDA
	Endif
	
	/* Flag que indica se o veiculo foi reservado */
	VV0->VV0_RESERV := M->VV0_RESERV
	if VV0->VV0_RESERV $ "1/3" // 1 reservado 3 venda futura
		if Empty(M->VV0_DATVAL)
			M->VV0_DATVAL := dDataBase+1
		Endif
		VV0->VV0_DATVAL := M->VV0_DATVAL //Data da Validade da Reserva do Veiculo
	Endif
	If M->VV0_OPEMOV == "0" .and. cTipFat == "2"
		VVA->VVA_TRACPA := "FATDIR"
	Endif
	MsUnlock()
	
	RecLock("VVA",.f.)
	if M->VV0_AUTFAT == "0"
		aAdd(aVetTra,{VV0->VV0_CODVEN,1})
		If FunName() $ "VEIVM011.VEIVMM01"
			If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
				ExecBlock("FS_COMVEI",.f.,.f.)
				VVA->VVA_COMVDE := M->VVA_COMVDE
				ExecBlock("FS_COMVEI",.f.,.f.)
				VVA->VVA_COMGER := M->VVA_COMGER
				VVA->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMVDE}} )
				VVA->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMGER}} )
			Else
				aValCom    := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValBasCom,"T")
				VVA->VVA_COMVDE := aValCom[1]
				VVA->VVA_COMGER := aValCom[2]
				aValCom    := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValBasCom,"D")
				VVA->VVA_CMFVDE := FG_CalcMF(  aValCom[1] )
				VVA->VVA_CMFGER := FG_CalcMF(  aValCom[2] )
			Endif
		Endif
	Else
		aAdd(aVetTra,{VV0->VV0_CODVEN,1})
		If FunName() $ "VEIVM011.VEIVMM01"
			If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
				ExecBlock("FS_COMVEI",.f.,.f.)
				VVA->VVA_COMVDE := M->VVA_COMVDE
				ExecBlock("FS_COMVEI",.f.,.f.)
				VVA->VVA_COMGER := M->VVA_COMGER
				VVA->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMVDE}} )
				VVA->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMGER}} )
			Else
				aValCom    := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValBasCom,"T")
				VVA->VVA_COMVDE := aValCom[1]
				VVA->VVA_COMGER := aValCom[2]
				aValCom    := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValBasCom,"D")
				VVA->VVA_CMFVDE := FG_CalcMF(  aValCom[1] )
				VVA->VVA_CMFGER := FG_CalcMF(  aValCom[2] )
			Endif
		Endif
	Endif
Endif
dbSelectarea("VVA")
MsUnlock()

IncProc(STR0339) //Atualizando Situacao do Veiculo...
dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+M->VV0_CHASSI)
RecLock("VV1",.f.)
VV1->VV1_NUMTRA := VVA->VVA_NUMTRA
If cTipSai <> "3" .and. cTipSai <> "2" // Diferente de Remessa e Transferencia
	VV1->VV1_STATUS := "  "
EndIf
If M->VV0_OPEMOV == "0" .and. cTipFat == "2"
	VV1->VV1_TRACPA := "FATDIR"
	VV1->VV1_SITVEI := "1"
Endif
if cTipFat == "2" // Faturamento Direto
	VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
	cCodFab := VE4->VE4_CODFAB
	SA1->(dbSeek(xFilial("SA1")+VE4->VE4_CODFAB+VE4->VE4_LOJA))
	if lA1_IBGE
		FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
		VV1->VV1_CIDANT := VAM->VAM_DESCID
		VV1->VV1_ESTANT := VAM->VAM_ESTADO
	else
		VV1->VV1_CIDANT := SA1->A1_MUN
		VV1->VV1_ESTANT := SA1->A1-EST
	endif
	VV1->VV1_NOMANT := SA1->A1_NOME
	VV1->VV1_ENDANT := SA1->A1_END
	VV1->VV1_CEPANT := SA1->A1_CEP
	VV1->VV1_DOCIND := SA1->A1_CGC
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	if dbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
		if lA1_IBGE
			FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
			VV1->VV1_CIDANT := VAM->VAM_DESCID
			VV1->VV1_ESTANT := VAM->VAM_ESTADO
		else
			VV1->VV1_CIDANT := SA1->A1_MUN
			VV1->VV1_ESTANT := SA1->A1_EST
		endif
		
		VV1->VV1_NOMANT := SA1->A1_NOME
		VV1->VV1_ENDANT := SA1->A1_END
		VV1->VV1_CEPANT := SA1->A1_CEP
		VV1->VV1_DOCIND := SA1->A1_CGC
	Endif
Endif     
If !( FunName() $ "VEIVM015.VEIVM017" )
	VV1->VV1_PROATU := M->VV0_CODCLI
	VV1->VV1_LJPATU := M->VV0_LOJA
endif
Do Case
	Case cTipSai == "0" // Venda
		if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") // Faturamento
			VV1->VV1_SITVEI := "1" // Vendido
			VV1->VV1_DATVEN := ddatabase
		Else
			if VV0->VV0_AUTFAT == "1"
				If VV0->VV0_TIPFAT != "2" // Nao for Fat. Direto
					VV1->VV1_RESERV := "1" // Reservado
				Endif
				VV1->VV1_DTHRES := Dtoc(dDataBase) + [/] + Time()
				VV1->VV1_DTHVAL := " "
			Else
				if VV0->VV0_RESERV $ "1/3" // Reserva 3- venda futura - Manoel/rafael
					VV1->VV1_RESERV := "1" // Reservado
					VV1->VV1_DTHRES := Dtoc(dDataBase) + [/] + Time()
					VV1->VV1_DTHVAL := Dtoc(M->VV0_DATVAL) + [/] + Time()
				Else
					If cTipFat != "2"
						VV1->VV1_SITVEI := "0" // Liberado
					Endif
					VV1->VV1_DTHRES := " "
					VV1->VV1_DTHVAL := " "
				Endif
			Endif
		Endif
	Case cTipSai == "1" // Simulacao
		VV1->VV1_SITVEI := "0" // Estoque
	Case cTipSai == "3" // Remessa
		VV1->VV1_SITVEI := "3" // Remessa
	Case cTipSai == "2" // Transferencia
		VV1->VV1_SITVEI := "5" // Transferido
	Case cTipSai == "4" // Devolucao
		VV1->VV1_SITVEI := " " // Estoque
		If cTip == "G"
			VV1->VV1_TRACPA := Space(10)
			VV1->VV1_NUMTRA := Space(10)
		Endif
	Case cTipSai == "6" // Retorno da Entrada por Remessa
		VV1->VV1_SITVEI := " " //Nao esta no Estoque
EndCase
MsUnlock()

// Manoel - 19.Out.2004
dbSelectArea("VO5")
dbSetOrder(1)
If dbSeek(xFilial("VO5")+VV1->VV1_CHAINT)
	If cTipSai == "0" // Venda
		if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") // Faturamento
			RecLock("VO5",.f.)
			VO5->VO5_DATVEN := dDataBase
			MsUnlock()
		Endif
	Endif
Endif

If FunName() == "VEIVM010"
	//FS_AtuVZ7("I") // Inclusao ou Alteracao dos Itens de Campanha
Endif

if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") .and. cTipSai <> "4"  //Devolucao
	dbSelectArea("VV0")
	nRecVV0 := recno()
	dbSelectArea("VVA")
	nRecVVA := recno()
	FS_ApagSimul()
	dbSelectArea("VVA")
	dbGoto(nRecVVA)
	dbSelectArea("VV0")
	dbGoto(nRecVV0)
Endif

lJaGrv := .t.

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VLD      ³ Autor ³  Manoel               ³ Data ³ 13/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos Get's                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VLD(Arg,lMsg)

Local oCodTra
Local bCampo3       := { |nCPO| FieldName(nCPO) }
Local cSavAlias     := Alias()
Local nCustoVeiculo := 0
Local cNORTE        := GetMv("MV_NORTE")
Local mvIncent      := GetNewPar("MV_INCENT",0)
Local nValTab       := 0
Local nValCus       := 0
Local nValRpr       := 0
Local nValRmt       := 0
Local nxi			:= 0

DEFAULT lMsg := .t.

lRet := .f.

if Arg == 1
	
	if ReadVar() = "M->VV0_CHASSI"
		M->VVA_CHASSI := M->VV0_CHASSI
	Endif
	
	if Empty(M->VVA_CHASSI)
		if lMsg
			MsgInfo(STR0340 ,STR0015) //Veiculo tem que ser informado! - Atencao !
		Endif
		Return .f.
	Endif
	
	if !Inclui
		if M->VVA_CHASSI <> VVA->VVA_CHASSI
			if lMsg
				MsgInfo(STR0341 ,STR0015) //Nao e possivel alterar o veiculo de uma proposta ja gravada! - Atencao !
			Endif
			Return .f.
		Endif
	Endif
	
	//Por Chassi Interno
	if len(AllTrim(M->VVA_CHASSI)) == 6
		VV1->(dbSetOrder(1))
		if VV1->(dbSeek(xFilial("VV1")+M->VVA_CHASSI))
			M->VVA_CHASSI := VV1->VV1_CHASSI
		Endif
	Endif
	
	//Por Chassi
	VV1->(dbSetOrder(2))
	if !VV1->(dbSeek(xFilial("VV1")+M->VVA_CHASSI))
		if lMsg
			MsgInfo(STR0342,STR0015) //Veiculo nao encontrado no cadastro, Verifique a informacao digitada! - Atencao !
		Endif
		Return .f.
	Endif
	
	If cTipFat == "2" .and. cParPrg # "3"
		if VV1->VV1_SITVEI != " "
			MsgInfo(STR0343 ,STR0015 ) //Este veiculo nao tem situacao valida para ser Faturado Direto! - Atencao !
			Return .f.
		Endif
	Endif
	
	//Valida situacao do veiculo
	if VV1->VV1_SITVEI == "1" //Vendido
		MsgInfo(STR0344 ,STR0015) //Veiculo esta Vendido! - Atencao !
		Return .f.
	Endif
	if VV1->VV1_SITVEI == "3" //Remessa
		MsgInfo(STR0345 ,STR0015) //Veiculo de Remessa! - Atencao !
		Return .f.
	Endif
	if VV1->VV1_SITVEI == "4" //Consignado
		MsgInfo(STR0346 ,STR0015) //Veiculo Consignado! - Atencao !
		Return .f.
	Endif
	
	M->VVA_CHAINT := VV1->VV1_CHAINT
	M->VVA_ESTVEI := if(VV1->VV1_ESTVEI="0",STR0316,STR0317) //novo - usado
	
	M->VV0_CHAINT := VV1->VV1_CHAINT
	M->VV0_DESMAR := POSICIONE("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR")
	M->VV0_CODMAR := VE1->VE1_CODMAR
	M->VV0_DESMOD := POSICIONE("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD")
	M->VV0_MODVEI := VV2->VV2_MODVEI
	M->VV0_DESCOR := POSICIONE("VVC",1,xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI,"VVC_DESCRI")
	M->VV0_CORVEI := VVC->VVC_CORVEI
	M->VV0_FABMOD := VV1->VV1_FABMOD
	M->VV0_PLAVEI := VV1->VV1_PLAVEI
	
	//Cria variaveis de memoria dos campos de veiculos
	dbSelectArea("VV1")
	For nxi:=1 to FCount()
		&("M->"+(EVAL(bCampo3,nxi))) := &("VV1->"+(EVAL(bCampo3,nxi)))
	Next
	M->VVA_CHAINT := VV1->VV1_CHAINT
	
	//Grava nro da transacao atual
	cNumTra := M->VV0_NUMTRA
	
	//Se o veiculo nao estiver no estoque ou estiver reservado nao deixa vender
	dbSelectArea("VV0")
	aAreaVV0 := GetArea()
	dbSelectArea("VVA")
	aAreaVVA := GetArea()
	dbSeek(xFilial("VVA")+VV1->VV1_NUMTRA)
	if VV0->VV0_RESERV $ "1/3" // 1 reservado 3 venda futura
		if VV1->VV1_SITVEI <> "0" .and. VVA->VVA_NUMTRA <> cNumTra .and. Empty(VV0->VV0_NUMNFI)
			if lMsg
				MsgInfo(STR0347 +VVA->VVA_NUMTRA,STR0015) //Este Veiculo esta Reservado Pela Proposta nro. Atencao!
			Endif
			RestArea(aAreaVV0)
			dbSelectArea("VVA")
			RestArea(aAreaVVA)
			Return(.f.)
		Endif
	Endif
	
	dbSelectArea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+VV1->VV1_NUMTRA)
	if VV0->VV0_AUTFAT == "1" .and. VV0->VV0_NUMTRA <> cNumTra .and. Empty(VV0->VV0_NUMNFI)
		if lMsg
			MsgInfo(STR0347 +VV0->VV0_NUMTRA,STR0015) //Este Veiculo esta Reservado Pela Proposta nro. Atencao!
		Endif
		RestArea(aAreaVV0)
		dbSelectArea("VVA")
		RestArea(aAreaVVA)
		Return(.f.)
	Endif
	RestArea(aAreaVV0)
	
	dbSelectArea("VVA")
	RestArea(aAreaVVA)
	
	if Inclui .and. nOpc == 3
		FS_CARDAD(nOpc)
	Endif
	
	// Gerencial
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)
	nCustoVeiculo := 0
	if cTipFat == "0"
		If !Empty(VV2->VV2_FORCTB)       //Modelo do Veiculo
			nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCTB)
		ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora
			nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
		Endif
		if ValType(nCustoVeiculo) <> "N"
			nCustoVeiculo := 0
		Endif
	Else
		cFor := GetMv("MV_VUCGER")
		if !Empty(cFor)
			nCustoVeiculo := FG_FORMULA(cFor)
			if ValType(nCustoVeiculo) <> "N"
				nCustoVeiculo := 0
			Endif
		Endif
	Endif
	
	if nCustoVeiculo <= 0
		dbSelectArea("VVG")
		dbSetOrder(1)
		if dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)
			nCustoVeiculo := VVG->VVG_VCNVEI
		Endif
	Endif
	
	dbSelectArea("VVD")
	dbSetOrder(1)
	if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
		while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
			if VVD->VVD_ATUCUS=="1"
				nCustoVeiculo += VVD->VVD_VALOR
			Endif
			dbSelectArea("VVD")
			dbSkip()
		Enddo
	Endif
	
	dbSelectArea("VVA")
	
	M->VVA_VCAVEI := nCustoVeiculo
	
	//Funcao que traz o valor sugerido p/ o modelo + acessorios
	if M->VV0_VALMOV == 0
		M->VVA_VALVDA := FS_VALVDA()
		M->VV0_VALMOV := M->VVA_VALVDA
	Else
		M->VVA_VALVDA := M->VV0_VALMOV
	Endif
	
	if M->VVA_VALVDA == 0
		M->VVA_VALVDA := nCustoVeiculo
		M->VV0_VALMOV := nCustoVeiculo
	Endif
	
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR))
	cDesMar := VE1->VE1_DESMAR
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
	cDesMod := VV2->VV2_DESMOD
	nBonus  := 0
	if FG_SEEK("VVO","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD",1,.f.)
		while VVO->(!EOF()) .and. VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD == VVO->VVO_CODMAR+VVO->VVO_MODVEI+VVO->VVO_SEGMOD
			nBonus  := VVO->VVO_VALBON
			VVO->(!dbSkIP())
		Enddo
	Endif
	if Empty(M->VVA_BONFAB)
		M->VVA_BONFAB := if(VV1->VV1_ESTVEI=="0" .or. cTipFat == "2",nBonus,0)
	Endif
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI))
	cDesCor := Subs(VVC->VVC_DESCRI,1,19)
	
	//andre bloco que esta na fs_cartes
	
	if cTipFat == "2"  //Faturamento Direto
		if !Ve010Inc(M->VVA_CHASSI)
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
	
	Return .t.
	
Elseif Arg == 2
	
	if Empty(M->VV1_CODMAR)
		Return .t.
	Else
		VE1->(dbSetOrder(1))
		if !VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR))
			Help(" ",1,"MCNCADM010")
			Return .f.
		Else
			cDesMar := VE1->VE1_DESMAR
			Return .t.
		Endif
	Endif
	
Elseif Arg == 3
	
	if Empty(M->VV1_MODVEI)
		Return .t.
	Else
		VV2->(dbSetOrder(1))
		if !VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
			Help(" ",1,"MVNCADM010")
			Return .f.
		Else
			cDesMod := VV2->VV2_DESMOD
			M->VV1_MODVEI := cDesMod
			if Type("oModelo") <> "U"
				oModelo:Refresh()
			Endif
			if cEstoque == "N" .and. cNovUsa == "0" //Veiculo Novo
				
				&& Levanta preco atual da tabela.
				VVP->(dbSetOrder(1))
				VVP->(dbSeek(xFilial("VVP")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD+Dtos(dDataBase),.t.))
				
				nValTab := 0
				nValCus := 0
				
				If VVP->VVP_FILIAL+VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == xFilial("VVP")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD ;
					.And. VVP->VVP_DATPRC >= dDataBase
					
					nValTab := VVP->VVP_VALTAB
					nValCus := VVP->VVP_CUSTAB
					
				EndIf
				
				M->VVA_VALVDA := nValTab
				M->VVA_VCAVEI := nValCus + nValCor
				If !MaFisFound('NF')
					if Empty(M->VV0_CODCLI)
						help(" ",1,"CLNCADM010")
						Return .t.
					Endif
					if Empty(M->VVA_CODTES)
						help(" ",1,"INFTESM010")
						Return .t.
					Endif
				Endif
				FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
				FS_FisRef("IT_DESPESA",M->VV0_DESACE)
				FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
				if cEstoque == "N"
					M->VVA_VALMOV := M->VVA_VALVDA+nValEqp
				Else
					M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
				Endif
				if cTipFat == "2"
					M->VVA_VBAICM := 0
					M->VVA_ICMVEN := 0
					M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
					nTotEnt := M->VVA_VALCVD
				Else
					if cEstoque == "S"
						M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
						M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
					Endif
					nTotEnt := M->VVA_VALMOV
				Endif
				
			Endif
			
			Return .t.
			
		Endif
	Endif
	
Elseif Arg == 4
	
	If Empty(M->VV1_CORVEI)
		Return .t.
	Else
		VVC->(dbSetOrder(1))
		If !VVC->(dbSeek(xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI))
			Help(" ",1,"CVNCADM010")
			Return .f.
		Else
			cDesCor := Subs(VVC->VVC_DESCRI,1,19)
			cTipCor := VVC->VVC_TIPCOR
			if Type("oDesCor") <> "U"
				oDesCor:refresh()
			Endif
			
			&& Levanta preco atual da tabela.
			VVP->(dbSetOrder(1))
			VVP->(dbSeek(xFilial("VVP")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD+Dtos(dDataBase),.t.))
			
			nValRpr := 0
			nValRmt := 0
			nValCus := 0
			
			If VVP->VVP_FILIAL+VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == xFilial("VVP")+M->VV1_CODMAR+M->VV1_MODVEI+M->VV1_SEGMOD ;
				.And. VVP->VVP_DATPRC >= dDataBase
				
				nValRpr := VVP->VVP_VACRPR
				nValRmt := VVP->VVP_VACRMT
				nValCus := VVP->VVP_CUSTAB
				
			EndIf
			
			if cNovUsa == "0"        // Veiculo Novo
				if cTipCor == "2"     // Perolizada
					nValCor := nValRpr
				Elseif cTipCor == "1" // Metalica
					nValCor := nValRmt
				Else
					nValCor := 0
				Endif
			Else
				nValCor := 0
			Endif
			M->VVA_VCAVEI := nValCus + nValCor
			M->VVA_VALMOV := M->VVA_VALMOV + M->VVA_VCAVEI
			if cEstoque == "S"
				If !MaFisFound('NF')
					if Empty(M->VV0_CODCLI)
						help(" ",1,"CLNCADM010")
						Return .t.
					Endif
					if Empty(M->VVA_CODTES)
						help(" ",1,"INFTESM010")
						Return .t.
					Endif
				Endif
				
				FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
				FS_FisRef("IT_DESPESA",M->VV0_DESACE)
				FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
				M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
			Endif
			
			if cTipFat == "2"
				M->VVA_VBAICM := 0
				M->VVA_ICMVEN := 0
				M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
				nTotEnt := M->VVA_VALCVD
			Else
				if cEstoque == "S"
					M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
					M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
				Endif
				nTotEnt := M->VVA_VALMOV
			Endif
			
			Return .t.
		Endif
		
	Endif
	
Elseif Arg == 5
	
	nValSCor := M->VVA_VCAVEI + nValCor
	If !MaFisFound('NF')
		if Empty(M->VV0_CODCLI)
			help(" ",1,"CLNCADM010")
			Return .t.
		Endif
		if Empty(M->VVA_CODTES)
			help(" ",1,"INFTESM010")
			Return .t.
		Endif
	Endif
	if cEstoque == "S"
		FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
		FS_FisRef("IT_DESPESA",M->VV0_DESACE)
		FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
		M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	Else
		M->VVA_VALMOV := M->VVA_VALVDA + nValCor
	Endif
	
	if cTipFat == "2"
		M->VVA_VBAICM := 0
		M->VVA_ICMVEN := 0
		M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
		nTotEnt := M->VVA_VALCVD
	Else
		if cEstoque == "S"
			M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
			M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		Endif
		nTotEnt := M->VVA_VALMOV
	Endif
	
	Return .t.
	
Elseif Arg == 6
	
	if cParPrg == "1" .or. cTipFat == "2" .or. M->VV0_OPEMOV $ "2346"
		Return .t.
	Endif
	
	If M->VVA_RECTEC > 0
		FS_VALMOVTO()
	Endif
	
	Return .t.
	
Elseif Arg == 7  //Codigo do Cliente
	
	cEstCli := ""
	If !Empty(M->VV0_CODCLI)
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI))
			Help(" ",1,"CLNCADM010")
			Return .f.
		Else
			if lA1_IBGE
				FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
				cEstCli := VAM->VAM_ESTADO
			else
				cEstCli := SA1->A1_EST
			endif
			M->VV0_LOJA:= SA1->A1_LOJA
			cNomCli := SA1->A1_NOME
		Endif
	Else
		Return .f.
	Endif
	
	if !Empty(M->VVA_CHASSI)
		if cTipFat == "2"
			M->VVA_VBAICM := 0
			M->VVA_ICMVEN := 0
			M->VVA_ALIICM := 0
		Else
			If MaFisFound('NF')
				M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
				M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
				if cTipFat == "0"   //Novo
					M->VVA_ALIICM := Val(subs(GetMv("MV_ESTICM"),at(cEstCli,GetMv("MV_ESTICM"))+2,2))
					if mvIncent <> 0
						M->VVA_ALIICM := 	mvIncent
					Endif
				Elseif cTipFat == "1" //Usado
					FS_FisRef("IT_ALIQICM" ,M->VVA_ALIICM)
					M->VVA_ALIICM := MaFisRet(n,"IT_ALIQICM")
				Endif
			Endif
		Endif
	Endif
	
	oNomCli:Refresh()
	
Elseif Arg == 8
	
	If Empty(M->VV0_CODAVA)
		cNomAva := Space(20)
		Return .t.
	Else
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CODAVA))
			Help(" ",1,"AVNCADM010")
			Return .f.
		Else
			M->VV0_LOJAAV := SA1->A1_LOJA
			cNomAva  := SA1->A1_NOME
			Return .t.
		Endif
	Endif
	
	
Elseif Arg == 9
	
	if  !VV3->VV3_ALIARR == "S"
		If Empty(M->VV0_CLIALI)
			cNomAli := Space(20)
			Return .t.
		Else
			SA1->(dbSetOrder(1))
			if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIALI))
				help(" ",1,"ALNCADM010") //"Cliente Alienacao Informado nao Existe no Cadastro!"
				Return .f.
			Else
				M->VV0_LOJALI := SA1->A1_LOJA
				cNomAli  := SA1->A1_NOME
				Return .t.
			Endif
		Endif
	Else
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIALI))
			Help(" ",1,"ALNCADM010") //"Cliente Alienacao Informado nao Existe no Cadastro!"
			Return .f.
		Else
			M->VV0_LOJALI := SA1->A1_LOJA
			Return .t.
		Endif
	Endif
	
Elseif Arg == 10
	
	If !MaFisFound('NF')
		Return .t.
	Endif
	if cEstoque == "S"
		FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
		FS_FisRef("IT_ALIQICM",M->VVA_ALIICM)
		FS_FisRef("IT_DESPESA",M->VV0_DESACE)
		FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
		M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
		if  cTipFat == "2"
			M->VVA_VBAICM := 0
			M->VVA_ICMVEN := 0
		Else
			M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
			M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		Endif
	Else
		M->VVA_VALMOV := M->VVA_VALVDA+nValEqp
	Endif
	
	Return .t.
	
Elseif Arg == 11
	
	If Empty(M->VV0_FORPAG)
		cDesFpg := Space(15)
		Return .t.
	Else
		SE4->(dbSetOrder(1))
		if !SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
			Help(" ",1,"CPNCADM010")
			Return .f.
		Else
			cTipPag := M->VV0_FORPAG
			cDesPag := alltrim(SE4->E4_DESCRI)
			cDesFpg := alltrim(SE4->E4_DESCRI)
			Return .t.
		Endif
	Endif
	
Elseif Arg == 12
	
	If Empty(M->VV0_EMPCON)
		Return .t.
	Else
		VV4->(dbSetOrder(1))
		if !VV4->(dbSeek(xFilial("VV4")+M->VV0_EMPCON))
			help(" ",1,"CONCADM010")
			Return .f.
		Else
			cNomCon := VV4->VV4_DESCRI
			Return .t.
		Endif
	Endif
	
Elseif Arg == 13
	
	if cEstoque == "S"
		If !MaFisFound('NF')
			Return .t.
		Endif
		
		if cTipFat == "2"
			FS_FisRef("IT_VALMERC",M->VVA_VALCVD)
			M->VVA_ISSCVD := MaFisRet(,"NF_VALISS")
		Else
			FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
		Endif
		
		FS_FisRef("IT_DESPESA",M->VV0_DESACE)
		FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
		M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	Else
		if cTipFat == "2"
			nTotEnt := M->VVA_VALCVD
			M->VVA_VALMOV := nTotEnt
		Else
			M->VVA_VALMOV := M->VVA_VALVDA + nValCor
			nTotEnt := M->VVA_VALMOV
		Endif
	Endif
	
	if cTipFat == "2" //Faturamento Direto
		M->VVA_VBAICM := 0
		M->VVA_ICMVEN := 0
		M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
		nTotEnt := M->VVA_VALCVD
	Else
		if cEstoque == "S"
			M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
			M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		Endif
		nTotEnt := M->VVA_VALMOV
	Endif
	
	if M->VVA_VBAICM == 0
		M->VVA_ALIICM := 0
	Endif
	
	Return .t.
	
Elseif Arg == 14
	
	If Empty(M->VV0_TIPVEN)
		cDesTvd := ""
		Return .t.
	Else
		VV3->(dbSetOrder(1))
		If !VV3->(dbSeek(xFilial("VV3")+M->VV0_TIPVEN))
			Help(" ",1,"TVNCADM010")
			Return .f.
		Else
			cDesTvd := Subs(VV3->VV3_DESCRI,1,15)
			Return .t.
		Endif
	Endif
	
Elseif Arg == 15   //Codigo do Vendedor
	
	FS_ATRSX3("VV0_CODVEN")
	
	VEK->(dbSetOrder(1))
	If ! VEK->(dbSeek(xFilial('VEK')+M->VV0_CODVEN))
		Help("  ",1,"CNOCOMISS")
	EndIf
	
	If !Empty(M->VV0_CODVEN)
		SA3->(dbSetOrder(1))
		If !SA3->(dbSeek(xFilial("SA3")+M->VV0_CODVEN))
			Help(" ",1,"VDNCADM010")
			Return .f.
		Else
			cNomVen := Subs(SA3->A3_NOME,1,15)
		Endif
	Else
		cNomVen := ""
		Return .f.
	Endif
	
Elseif Arg == 16
	
	If Empty(M->VV0_CODBCO)
		cNomBco := Space(15)
		M->VV0_CODAGE := Space(5)
		Return .t.
	Else
		SA6->(dbSetOrder(1))
		if !SA6->(dbSeek(xFilial("SA6")+M->VV0_CODBCO))
			Help(" ",1,"BCNCADM010")
			Return .f.
		Else
			cNomBco := SA6->A6_NREDUZ
			M->VV0_CODAGE := SA6->A6_AGENCIA
			Return .t.
		Endif
	Endif
	
Elseif Arg == 17
	
	if Empty(M->VV0_CODCLI)
		Help(" ",1,"NECINFCLIE")
		M->VVA_CODTES := Space(3)
		Return .t.
	Endif
	
	If !Empty(M->VVA_CODTES)
		SF4->(dbSetOrder(1))
		If !SF4->(dbSeek(xFilial("SF4")+M->VVA_CODTES))
			Help(" ",1,"TESNCDM010")
			Return .f.
		Else
			if !Val(M->VVA_CODTES) >= 500
				help(" ",1,"TESINVM010")
				Return .f.
			Endif
		Endif
	Else
		Return .f.
	Endif
	
	if cTipSai == "6" //Retorno da Entrada por Remessa
		if SF4->F4_PODER3 <> "D" //Devolucao
			MsgInfo(STR0348 ,STR0015) //O TES tem que controlar poder de terceiro na DEVOLUCAO! - Atencao!
			Return .f.
		Endif
	Elseif cTipSai == "3" //Remessa
		if SF4->F4_PODER3 <> "R" //Remessa
			MsgInfo(STR0349 ,STR0015) //O TES tem que controlar poder de terceiro na REMESSA! - Atencao!
			Return .f.
		Endif
	Endif
	
	if cTipSai $ "23" //Remessa e Transferencia
		if SF4->F4_ICM == "N"
			lBaseIcm := .f.
			lValIcm  := .f.
		Else
			lBaseIcm := .t.
			lValIcm  := .t.
		Endif
	Endif
	
	Return .t.
	
Elseif Arg == 18
	
	If !Empty(M->VV0_LOJA)
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA))
			Help(" ",1,"LJNCADM010")
			Return .f.
		Else
			if lA1_IBGE
				FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
				cEstCli := VAM->VAM_ESTADO
			else
				cEstCli := SA1->A1_EST
			endif
			cNomCli := SA1->A1_NOME
		Endif
	Else
		Return .f.
	Endif
	
	oNomCli:Refresh()
	
Elseif Arg == 19
	
	If Empty(M->VV0_LOJAAV)
		cNomAva := Space(20)
		Return .t.
	Else
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CODAVA+M->VV0_LOJAAV))
			help(" ",1,"LJNCADM010")
			Return .f.
		Else
			cNomAva  := SA1->A1_NOME
			Return .t.
		Endif
	Endif
	
Elseif Arg == 20
	
	If Empty(cCodFor)
		Return .t.
	Else
		SA2->(dbSetOrder(1))
		if !SA2->(dbSeek(xFilial("SA2")+cCodFor))
			Help(" ",1,"FORNCDM010")
			Return .f.
		Else
			if lA2_IBGE
				FG_Seek("VAM","SA2->A2_IBGE",1,.f.)
				cEstCli := VAM->VAM_ESTADO
			else
				cEstCli := SA2->A2_EST
			endif
			cLojaFor:= SA2->A2_LOJA
			cNomFor := SA2->A2_NREDUZ
			Return .t.
		Endif
	Endif
	
Elseif Arg == 21
	
	If Empty(cLojaFor)
		Return .t.
	Else
		SA2->(dbSetOrder(1))
		if !SA2->(dbSeek(xFilial("SA2")+cCodFor+cLojaFor))
			help(" ",1,"LJNCADM010")
			Return .f.
		Else
			if lA2_IBGE
				FG_Seek("VAM","SA2->A2_IBGE",1,.f.)
				cEstCli := VAM->VAM_ESTADO
			else
				cEstCli := SA2->A2_EST
			endif
			cNomFor := SA2->A2_NREDUZ
			Return .t.
		Endif
	Endif
	
Elseif Arg == 22
	
	if  !VV3->VV3_ALIARR == "S"
		If Empty(M->VV0_LOJALI)
			cNomAli := Space(20)
			Return .t.
		Else
			SA1->(dbSetOrder(1))
			if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIALI+M->VV0_LOJALI))
				Help(" ",1,"ALNCADM010") //"Cliente Alienacao Informado nao Existe no Cadastro!"
				Return .f.
			Else
				cNomAli  := SA1->A1_NOME
				Return .t.
			Endif
		Endif
	Else
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIALI+M->VV0_LOJALI))
			Help(" ",1,"ALNCADM010") //"Cliente Alienacao Informado nao Existe no Cadastro!"
			Return .f.
		Endif
	Endif
	
Elseif Arg == 23
	
	If Empty(M->VV0_AGEFIN)
		Return .t.
	Else
		SA6->(dbSetOrder(1))
		if !SA6->(dbSeek(xFilial("SA6")+M->VV0_AGEFIN))
			Help(" ",1,"AFNCADM010") //"Agente Financeiro Informado nao Existe no Cadastro!"
			Return .f.
		Else
			cNomAGF := SA6->A6_NREDUZ
			Return .t.
		Endif
	Endif
	
Elseif Arg == 24
	
	if Subs(cTransp,1,1) == "1"
		
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0160) FROM  02,04 TO 8,47 OF oMainWnd
		@ 04,004 SAY OemToAnsi(STR0161) OF oDlg PIXEL COLOR CLR_BLUE
		@ 04,044 MSGET oCodTra VAR M->VV0_CODTRA PICTURE "@!" F3 "SA4"  OF oDlg PIXEL COLOR CLR_BLACK
		
		DEFINE SBUTTON FROM 29,24 TYPE 1 ACTION (oDlg:End());
		ENABLE OF oDlg
		DEFINE SBUTTON FROM 29,55 TYPE 2 ACTION ();
		ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTER
		
	Endif
	
Elseif Arg == 25
	
	If Empty(M->VV0_CLIFTD)
		cNomCFtd := ""
		Return .t.
	Else
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIFTD))
			Help(" ",1,"CLNCADM010")
			Return .f.
		Else
			M->VV0_LOJFTD := SA1->A1_LOJA
			cNomCFtd := SA1->A1_NOME
			Return .t.
		Endif
	Endif
	
Elseif Arg == 26
	
	If Empty(M->VV0_LOJFTD)
		cNomCFtd := ""
		Return .t.
	Else
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIFTD+M->VV0_LOJFTD))
			Help(" ",1,"LJNCADM010")
			Return .f.
		Else
			cNomCFtd := SA1->A1_NOME
			Return .t.
		Endif
	Endif
	
Elseif Arg == 27
	if cEstoque == "N"
		Return .t.
	Endif
	
	if cTipFat == "2"
		FS_FisRef("IT_VALMERC",M->VVA_VALCVD)
		M->VVA_ISSCVD := MaFisRet(,"NF_VALISS")
	Else
		FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
	Endif
	FS_FisRef("IT_DESPESA" ,M->VV0_DESACE)
	FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
	M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	if  cTipFat == "2"
		M->VVA_VBAICM := 0
		M->VVA_ICMVEN := 0
		M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
		nTotEnt := M->VVA_VALCVD
	Else
		M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
		M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		nTotEnt := M->VVA_VALMOV
	Endif
	
Elseif Arg == 28
	
	FS_VALMOVTO()
	
	Return .t.
	
Elseif Arg == 29
	
	cSavAlias := alias()
	
	DbSelectArea("SX5")
	If !DbSeek(xFilial("SX5")+"V4"+M->VV0_MODVDA)
		MsgStop(STR0350) //Modalidade de Venda nao encontrada no Cadastro de Modalidades de Venda (SX5 - Tabela V4)
		DbSelectArea(cSavAlias)
		Return
	Endif
	DbSelectArea(cSavAlias)
	
Endif

Return ( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FICHAVEI  ³ Autor ³  Manoel               ³ Data ³ 28/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra a avaliacao de Resultado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FICHAVEI(cOutMoed1,nOpc1,cSimVda1,cTipSai1)

Private aVetTra := {}

lMsErroAuto := .f.
cOutMoed    := cOutMoed1
cSimVda     := cSimVda1
cTipSai     := cTipSai1

if cParPrg == "1" // Simulacao
	M->VV0_OPEMOV := "1"
Else
	M->VV0_OPEMOV := "0"
Endif

if !lDigVda
	Return(.f.)
Endif

cCodMap := "001"
DEFINE MSDIALOG oDlgFV TITLE OemtoAnsi(STR0090) FROM  02,04 TO 09,27 OF oMainWnd   //Demonstracao do Resultado

@  15,06 SAY OemToAnsi(STR0093) OF oDlgFV PIXEL COLOR CLR_BLACK
@  15,52 MSGET oCodMap VAR cCodMap PICTURE "@!" F3 "VS5"  SIZE 34,3 OF oDlgFV PIXEL COLOR CLR_BLACK
@  02,02 TO 35,089  LABEL OemtoAnsi(STR0090)  OF oDlgFV PIXEL      //Informe a 2a. Moeda p/ Calculo

DEFINE SBUTTON FROM 37,24 TYPE 1 ACTION (nOpca1 := 1,oDlgFV:End())	ENABLE OF oDlgFV
DEFINE SBUTTON FROM 37,55 TYPE 2 ACTION (nOpca1 := 2,oDlgFV:End())	ENABLE OF oDlgFV

ACTIVATE MSDIALOG oDlgFV CENTER

if nOpca1 # 1
	Return .f.
Endif

cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

FS_SIMULAGRV()
FG_CalcVlrs(FS_VDRVM010(cTipFat,cCodMap))
If FunName() $ "VEIVM011.VEIVMM01"
	If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
		ExecBlock("FS_COMVEI",.f.,.f.) // Primeira Vez para Calcular Comissao do Vendedor
		ExecBlock("FS_COMVEI",.f.,.f.) // Segunda Vez para Calcular Comissao do Gerente ou Supervisor
		M->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMVDE}} )
		M->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMGER}} )
	Else
		If cTipFat == "2" //Faturamento Direto
			nValBasCom := M->VVA_VALCVD
		Else
			nValBasCom := M->VVA_VALVDA
		Endif
		aValCom       := FG_COMISS("V",aVetTra,M->VV0_DATMOV,M->VV0_TIPFAT,nValBasCom,"T")
		M->VVA_COMVDE := aValCom[1]
		M->VVA_COMGER := aValCom[2]
		aValCom       := FG_COMISS("V",aVetTra,M->VV0_DATMOV,M->VV0_TIPFAT,nValBasCom,"D")
		M->VVA_CMFVDE := FG_CalcMF(  aValCom[1] )
		M->VVA_CMFGER := FG_CalcMF(  aValCom[2] )
	Endif
Endif
FG_CalcVlrs(FS_VDRVM010(cTipFat,cCodMap))
FG_ResAva(cOutMoed,nOpc1,cSimVda,cTipSai,"VEIVM010")

if nOpcaX # 1
	Return .f.
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_TOKVM010  ³ Autor ³  Manoel               ³ Data ³ 28/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tudo Ok - Verifica dados antes da Gravacao / Simulacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TOKVM010()

Local aSavaCols  := {}
Local aSavaHead  := {}
Local lSlvAltera := Altera
Local lSlvInclui := Inclui
Local lValorMin  := .f.
Local i			 := 0

Private lMsHelpAuto := .f.
Private lMsErroAuto := .f.

if nOpc == 2
	Return .t.
Endif

if Altera .or. Inclui
	if cEstoque == "S" .or. cTipFat == "2"  //Veiculo do Estoque
		If cTipSai == "4" //Devolucao
			if Empty(M->VVA_CODTES)
				Help(" ",1,"INFTESM010")
				oCodTes:SetFocus()
				Return .f.
			Endif
			SF4->(dbSetOrder(1))
			If !SF4->(dbSeek(xFilial("SF4")+M->VVA_CODTES))
				Help(" ",1,"TESNCDM010")
				oCodTes:SetFocus()
				Return .f.
			Else
				if !Val(M->VVA_CODTES) >= 500
					Help(" ",1,"TESINVM010")
					Return .f.
				Endif
			Endif
		Else
			if !lTelSim
				if cTipSai <> "6" //Retorno de Entrada por Remessa
					if VV1->VV1_SITVEI $ "1234" .and. (Inclui .or. Altera)
						If cTipFat != "2"
							Help(" ",1,"VEICJAVEND")
							Return .f.
						Endif
					Endif
					lOk2 := .f.
					if VV1->VV1_RESERV $ "1/3" // 1 reservado 3 venda futura
						lOk2 := .t.
						if !Empty(VV1->VV1_DTHVAL)
							dDatTmp := dToS(cToD(subs(VV1->VV1_DTHVAL,1,8)))
							dDatRes := Subs(dDatTmp,7,2) + "/" + Subs(dDatTmp,5,2) + "/" + Subs(dDatTmp,1,4)
							cHorTmp := subs(VV0->VV0_DTHEMI,10)
							if dDataBase > ctod(dDatRes)
								lOk2 := .f.
							Elseif dDataBase > ctod(dDatRes)
								if Time() > cHorTmp
									lOk2 := .f.
								Endif
							Endif
						Endif
					Endif
					
					if lOk2 .and. cParPrg <> "3" .and. nOpc <> 2 .and. cParPrg <> "3" .and. Alltrim(VVA->VVA_USUARI) <> Alltrim(Upper(Subs(cUsuario,7,15)))
						dbSelectArea("VVA")
						nRecVVA := Recno()
						dbSeek(xFilial("VVA")+VV1->VV1_NUMTRA)
						cDatS   := dToS(cToD(subs(VV1->VV1_DTHRES,1,8)))
						cDatRes := Subs(cDatS,7,2) + "/" + Subs(cDatS,5,2) + "/" + Subs(cDatS,1,4)
						cMensStr:= OemToAnsi(STR0264) + Alltrim(VVA->VVA_USUARI) + OemToAnsi(STR0265) + cDatRes + OemToAnsi(STR0266) + subs(VV1->VV1_DTHRES,10) + OemToAnsi(STR0267)
						MsgStop(OemToAnsi(cMensStr),OemtoAnsi(STR0015))
						dbGoto(nRecVVA)
						Return .f.
					Endif
				Endif
			Endif
			
			SA1->(dbSetOrder(1))
			if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA))
				Help(" ",1,"CLNCADM010")
				Return .f.
			Endif
			If cTipFat == "2" // Faturamento Direto
				VV1->(dbSetOrder(1))
				if !VV1->(dbSeek(xFilial("VV1")+M->VV1_CHAINT))
					Help(" ",1,"VENCADM010")
					Return .f.
				Endif
				
				SB1->(dbSetOrder(7))
				if !SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
					cLocal := GETMV("MV_LOCVEIN")
					aIncSB1:= {}
//					aAdd(aIncSB1,{"B1_COD"     ,VV1->VV1_CHAINT,Nil})
					aAdd(aIncSB1,{"B1_COD"     ,Left(GetMv("MV_GRUVEI")+Space(10),Len(SB1->B1_GRUPO))+"_"+VV1->VV1_CHAINT,Nil})
					aAdd(aIncSB1,{"B1_CODITE"  ,VV1->VV1_CHAINT,Nil})
					aAdd(aIncSB1,{"B1_DESC"    ,VV1->VV1_CHASSI,Nil})
					aAdd(aIncSB1,{"B1_TIPO"    ,GetMv("MV_TIPVEI"),Nil})
					aAdd(aIncSB1,{"B1_UM"      ,"UN"            ,Nil})
					aAdd(aIncSB1,{"B1_LOCPAD"  ,cLocal         ,Nil})
					aAdd(aIncSB1,{"B1_TS"      ,M->VVA_CODTES,Nil})
					aAdd(aIncSB1,{"B1_PRV1"    ,nTotEnt       ,Nil})
					aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"            ,Nil})
					aAdd(aIncSB1,{"B1_CONTRAT" ,"N"            ,Nil})
					aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"            ,Nil})
					aAdd(aIncSB1,{"B1_CODBAR"  ,VV1->VV1_CHAINT,Nil})
					aAdd(aIncSB1,{"B1_IRRF"    ,"N"            ,Nil})
					aAdd(aIncSB1,{"B1_CONTSOC" ,"N"            ,Nil})
					aAdd(aIncSB1,{"B1_MRP"     ,"N"            ,Nil})
					aAdd(aIncSB1,{"B1_GRUPO"   ,GetMv("MV_GRUVEI"),Nil})
					
					SB1->(dbSetOrder(1))
					
					MSExecAuto({|x| mata010(x)},aIncSB1)
					
					if lMsErroAuto
						Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo
						Return(.f.)
					Endif
					
				Endif
			Endif
			
			If cTipSai == "0"
				if  cParPrg <> "1" .and. cTipFat == "2"
					if Empty(M->VV0_NNFFDI)
						Help(" ",1,"VV0_NNFFDI")
						Return .f.
					Endif
				Endif
				
				if Subs(aHeader[1,2],1,3) == "VS9"
					aSavaCols := aClone(aCols)
					aSavaHead := aClone(aHeader)
					aColsC    := aClone(aCols)
					aHeaderC  := aClone(aHeader)
				Else
					aSavaCols := {}
					aSavaHead := {}
				Endif
				
				if nValorCom > 0 .and. !Empty(cCodCDCI)
					nTotEnt := nValorCom
				Endif
				
				//Variavel para validar se a Entrada + Financiamento Batem com o Valor Total
				nSubTotal1 := 0
				nSubTotal2 := 0
				if !Empty(aColsC[1,1]) .or. !Empty(aIteParc[1,1])
					For i:=1 to Len(aColsC)
						if !(aColsC[i,Len(aColsC[i])]) .and. !Empty(aColsC[i,FG_POSVAR("VS9_VALPAG","aHeaderC")])
							nSubTotal1 := nSubtotal1 + round(aColsC[i,FG_POSVAR("VS9_VALPAG","aHeaderC")],2)
						Endif
					Next
					For i:=1 to Len(aIteParc)
						if !Empty(aIteParc[i,2])
							nSubTotal2 := nSubtotal2 + round(aIteParc[i,2],2)
						Endif
					Next
				Else
					nSubTotal1 := nTotEnt
					nSubTotal2 := 0
				Endif
				
				if nSubTotal1 < 0 .or. nSubTotal2 < 0
					MsgInfo(STR0351 ,STR0015) //Nao pode haver valores negativos nas parcelas... - Atencao!!!
					Return(.f.)
				Endif
				
				nSubTotal := nSubTotal1+nSubTotal2
				
				if type("aSavaHead") # "U"
					if Subs(aSavaHead[1,2],1,3) == "VS9"
						aCols   := aClone(aSavaCols)
						aHeader := aClone(aSavaHead)
					Endif
				Endif
				if Round(nSubTotal,2) <> Round(nTotEnt,2)
					if nSubTotal1 > nTotEnt .and. nSubTotal2 == 0
						if !lTroca
							if !MsgYesNo(STR0352 ,STR0015) //Esta e uma TROCA com TROCO? - Atencao!!!
								MsgInfo(STR0353 ,STR0015) //Os valores digitados na entrada estao incorretos... - Atencao!!!
								Return(.f.)
							Else
								FG_DesfPag()
								lTroca := .t.
							Endif
						Endif
					Else
						MsgInfo(STR0354 ,STR0015) //Entrada + Financiamento nao Bate com Valor TOTAL... - Atencao !
						Return .f.
					Endif
				Endif
			Endif
			
			if cTipSai # "0" .and. cTipFat # "2" .and. cParPrg # "3"
				SE4->(dbSetOrder(1))
				if !SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
					Help(" ",1,"CPNCADM010")
					Return .f.
				Endif
			Else
				if (Empty(cTipPag) .and. Empty(M->VV0_FORPAG)) .and. cParPrg # "1"
					cTipPag        := RetCondVei()
					M->VV0_FORPAG := cTipPag
				Endif
			Endif
			if cParPrg == "2" .and. cTipSai <> "1"
				if Empty(cTransp)
					Help(" ",1,"RESPFRM010") // favor informe o responsavel pelo frete
					Return .f.
				Endif
				VV3->(dbSetOrder(1))
				if !VV3->(dbSeek(xFilial("VV3")+M->VV0_TIPVEN))
					Help(" ",1,"TVNCADM010")
					Return .f.
				Endif
				if !Empty(M->VV0_EMPCON)
					VV4->(dbSetOrder(1))
					if !VV4->(dbSeek(xFilial("VV4")+M->VV0_EMPCON))
						Help(" ",1,"CONCADM010")
						Return .f.
					Endif
				Endif
			Endif
			SA3->(dbSetOrder(1))
			If !SA3->(dbSeek(xFilial("SA3")+M->VV0_CODVEN)) .and. cParPrg # "3"
				Help(" ",1,"VDNCADM010")
				Return .f.
			Endif
			
			VV1->(dbSetOrder(1))
			if !VV1->(dbSeek(xFilial("VV1")+M->VVA_CHAINT))
				Help(" ",1,"VENCADM010")
				Return .f.
			Endif
			
			VV1->(dbSetOrder(1))
			if VV1->(dbSeek(xFilial("VV1")+M->VVA_CHAINT))
				if !VV1->VV1_SITVEI $ "05" .and. cTipFat <> "2"   //Faturamento Direto
					if VV1->VV1_RESERV $ "1/3" // 1 reservado 3 venda futura
						if nOpc <> 2 .and. Alltrim(VVA->VVA_USUARI) <> Alltrim(Upper(Subs(cUsuario,7,15)))
							dbSelectArea("VVA")
							nRecVVA := Recno()
							dbSeek(xFilial("VVA")+VV1->VV1_NUMTRA)
							cDatS   := dToS(cToD(subs(VV1->VV1_DTHRES,1,8)))
							cDatRes := Subs(cDatS,7,2) + "/" + Subs(cDatS,5,2) + "/" + Subs(cDatS,1,4)
							cMensStr:= STR0355 +" " + Alltrim(VVA->VVA_USUARI) + " "+ STR0356 +" " + cDatRes + " " + STR0357 + " " + subs(VV1->VV1_DTHRES,10) + "h"  //Este Veiculo foi reservado pelo(a) funcionario(a) - no dia - as
							MsgStop(OemToAnsi(cMensStr),OemtoAnsi(STR0015))
							dbGoto(nRecVVA)
							Return .f.
						Endif
					Elseif VV1->VV1_SITVEI == "1"
						MsgInfo(STR0358 ,STR0015) //Veiculo esta Vendido... - Atencao!
						Return .f.
					Else
						if cTipSai <> "6" //Remessa
							MsgInfo(STR0359 ,STR0015) //Veiculo nao esta disponivel... - Atencao!
							Return .f.
						Else
							if VV1->VV1_SITVEI <> "3"
								MsgInfo(STR0360 ,STR0015)//Veiculo nao esta em Remessa... - Atencao!
								Return .f.
							Endif
						Endif
					Endif
				Endif
			Endif
			
			VE1->(dbSetOrder(1))
			if !VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR)) .and. !cTipFat == "2" //Fat. Direto
				Help(" ",1,"MCNCADM010")
				Return .f.
			Endif
			
			SF4->(dbSetOrder(1))
			If !SF4->(dbSeek(xFilial("SF4")+M->VVA_CODTES))
				Help(" ",1,"TESNCDM010")
				Return .f.
			Else
				if !Val(M->VVA_CODTES) >= 500
					Help(" ",1,"TESINVM010")
					Return .f.
				Endif
			Endif
			
			If M->VVA_BONFAB > 0 .and. Empty(M->VVA_INPCBF)
				if MsgYesNo(OemToAnsi(STR0232),OemToAnsi(STR0015))
					M->VVA_INPCBF := "1"//Sim
				Else
					M->VVA_INPCBF := "0"//Nao
				Endif
			Endif
			
			If M->VVA_BONFAB > 0 .and. Empty(M->VVA_INISBF)
				if MsgYesNo(OemToAnsi(STR0234),OemToAnsi(STR0015))
					M->VVA_INISBF := "1" //Sim
				Else
					M->VVA_INISBF := "0" //Nao
				Endif
			Endif
			
			If !M->VVA_VALVDA > 0
				if cTipSai == "0" // Venda
					Help(" ",1,"VVDINVM010")
				Elseif cTipSai == "3" //Remessa
					Help(" ",1,"VRMINVM010")
				Elseif cTipSai == "2" //Transferencia
					Help(" ",1,"VTRINVM010")
				Endif
				Return(.f.)
			Endif
			
			if !cTipSai $ "36"
				if !FS_CREDITO(M->VV0_CODCLI,M->VV0_LOJA)
					if cParPrg # "1"
						Return .f.
					Endif
				Endif
			Endif
			
			if cTipSai == "0"
				//Verifica se nao precisa fazer pedido de liberacao p/ venda do veiculo
				VE4->(dbSetOrder(1))
				VE4->(dbSeek(xFilial("VE4")+M->VV1_CODMAR))
				nValorMin := FG_FORMULA(VE4->VE4_FVMIVD)   //Traz formula do valor minimo p/ venda do veiculo
				
				if ValType("nValorMin") # "N"
					nValorMin := 0
				Endif
				
				if nValorMin > 0
					if nValorMin > M->VVA_VALMOV
						lValorMin := .f.
					Else
						lValorMin := .t.
					Endif
				Else
					if M->VVA_VCAVEI > M->VVA_VALMOV
						lValorMin := .f.
					Else
						lValorMin := .t.
					Endif
				Endif
				
				//Se nao for simulacao e valor minimo nao alcancado gera pedido de liberacao
				If !lValorMin .and. cParPrg == "2" .and. cTipfat <> "2"
					if !lJaGrv
						nOpca    := 1
						lRetorno := Processa( {|| FS_FINVM010(nOpc,.t.) })
						if lRetorno
							lJaGrv := .t.
						Endif
					Endif
					if !Inclui .and. nValLib <> M->VVA_VALMOV
						FS_EXCLIB() // Exclui pedido de liberacao anterior
						Aviso( OemToAnsi(STR0269) , OemToAnsi(STR0270) , { OemToAnsi(STR0271) } )
						cNumLib := ""
					Endif
					if !Empty(cNumLib)
						if !FS_CHKLIB()
							Return(.f.)
						Endif
					Else
						FS_LIBVEI()
						Return(.f.)
					Endif
				Else
					if cParPrg == "2"
						FS_EXCLIB()
					Endif
				Endif
			Endif
		Endif
		
	Else
		
		If cTipSai == "0"
			if Subs(aHeader[1,2],1,3) == "VS9"
				aSavaCols := aClone(aCols)
				aSavaHead := aClone(aHeader)
				aColsC   := aClone(aCols)
				aHeaderC := aClone(aHeader)
			Else
				aSavaCols := {}
				aSavaHead := {}
			Endif
			
			if nValorCom > 0 .and. !Empty(cCodCDCI)
				nTotEnt := nValorCom
			Endif
			//Variavel para validar se a Entrada + Financiamento Batem com o Valor Total
			nSubTotal1 := 0
			nSubTotal2 := 0
			
			if !Empty(aColsC[1,1]) .or. !Empty(aIteParc[1,1])
				For i:=1 to Len(aColsC)
					if !(aColsC[i,Len(aColsC[i])])
						nSubTotal1 := nSubtotal1 + round(aColsC[i,4],2)
					Endif
				Next
				
				For i:=1 to Len(aIteParc)
					nSubTotal2 := nSubtotal2 + round(aIteParc[i,2],2)
				Next
			Else
				nSubTotal1 := nTotEnt
				nSubTotal2 := 0
			Endif
			
			if Type("aSavaHead") # "U"
				if Subs(aSavaHead[1,2],1,3) == "VS9"
					aCols   := aClone(aSavaCols)
					aHeader := aClone(aSavaHead)
				Endif
			Endif
			
			nSubTotal := nSubTotal1 + nSubTotal2
			
			if Round(nSubTotal,2) < Round(nTotEnt,2)
				MsgInfo(STR0235,STR0199)
				Return .f.
			Endif
			
			if Round(nSubTotal2,2) > Round(nTotEnt,2)
				MsgInfo(OemToAnsi(STR0272),OemToAnsi(STR0015))
				Return .f.
			Endif
			
		Endif
		
		SA3->(dbSetOrder(1))
		If !SA3->(dbSeek(xFilial("SA3")+M->VV0_CODVEN)) .and. cParPrg # "3"
			Help(" ",1,"VDNCADM010")
			Return .f.
		Endif
		
		SA1->(dbSetOrder(1))
		if !SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA))
			Help(" ",1,"CLNCADM010")
			Return .f.
		Endif
		
		VE1->(dbSetOrder(1))
		if !VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR)) .and. !cTipFat == "2" //Fat. Direto
			Help(" ",1,"MCNCADM010")
			Return .f.
		Endif
		
		SF4->(dbSetOrder(1))
		if !SF4->(dbSeek(xFilial("SF4")+M->VVA_CODTES))
			Help(" ",1,"TESNCDM010")
			Return .f.
		Else
			if !Val(M->VVA_CODTES) >= 500
				Help(" ",1,"TESINVM010")
				Return .f.
			Endif
		Endif
		
		If !M->VVA_VALVDA > 0
			if cTipSai == "0" // Venda
				Help(" ",1,"VVDINVM010")
			Elseif cTipSai == "3" //Remessa
				Help(" ",1,"VRMINVM010")
			Elseif cTipSai == "2" //Transferencia
				Help(" ",1,"VTRINVM010")
			Endif
			Return(.f.)
		Endif
	Endif
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OBSVEI ³ Autor ³  Manoel               ³ Data ³ 13/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Acionamento de campo MEMO atraves de Botao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OBSVEI(nOpc)

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0048) FROM  02,04 TO 14,56 OF oMainWnd //"Observacoes do Veiculo"

DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1
If nOpc == nil
	nopc := nopcao
endif
If Str(nOpc,1) $ "34"
	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
	oObserv:oFont := oFnt4
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()
Else
	@ 01,011 SAY cObserv OF oDlg1 SIZE 182,67 PIXEL
Endif

ACTIVATE MSDIALOG oDlg1 CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CREDITO³ Autor ³  Emilton              ³ Data ³ 26/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pesquisa Limite de Credito do Cliente                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CREDITO(cCodCli,cLoja)

If "V" $ GetMv("MV_CHKCRE")
	If !MaAvalCred( cCodCli, cLoja, M->VVA_VALVDA+FG_AVALCRED(cCodCli, cLoja), 1, .T. )
		Help(" ",1,"LIMITECRED")
		Return .f.
	Endif
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CARDAD ³ Autor ³  Manoel               ³ Data ³ 29/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega dados dos Arquivos em Variaveis                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CARDAD(nOpc)

//Local _ni, p_
//Local lNlBonus := .f.

lCarDad  := .t.
aIteDesp := {}
aIteRece := {}

cFunJEst := GetNewPar("MV_FUNJEST","") // Nome da Funcao que Calcula o Juros de Estoque

M->VVA_DESVEI := FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"D")
M->VVA_RECVEI := FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"R")

dDatVVF := ctod("")
nRegVVF := 0
dbSelectArea("VVG")
dbSetOrder(2)
if dbSeek(xFilial("VVG")+VV1->VV1_CHAINT)
	while !EOF() .and. VVG->VVG_CHAINT == VV1->VV1_CHAINT
		dbSelectArea("VVF")
		dbSetOrder(1)
		if dbSeek(xFilial("VVF")+VVG->VVG_TRACPA)
			if VVF->VVF_OPEMOV == "0" .and. VVF->VVF_DATMOV > dDatVVF
				dDatVVF := VVF->VVF_DATMOV
				nRegVVF := recno()
			Endif
		Endif
		dbSelectArea("VVG")
		dbSkip()
	Enddo
Endif

if nRegVVF > 0
	dbSelectArea("VVF")
	dbGoto(nRegVVF)
	
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial("VVG")+VVF->VVF_TRACPA+VV1->VV1_CHAINT)
Else
	dbSelectArea("VVG")
	dbSetOrder(2)
	dbSeek(xFilial("VVG")+VV1->VV1_CHAINT)
	
	dbSelectArea("VVF")
	dbSetOrder(1)
	dbSeek(xFilial("VVF")+VVG->VVG_TRACPA)
Endif

if VV1->VV1_CHAINT # cChaInter .and. !Empty(M->VVA_CHASSI) .and. cParPrg # "3"
	If Inclui
		lLevCam := .t.
	Endif
	cChaInter := VV1->VV1_CHAINT
	lOk2 := .f.
	if VV1->VV1_RESERV $ "1/3" // 1 reservado 3 venda futura
		lOk2 := .t.
		if !Empty(VV1->VV1_DTHVAL)
			dDatTmp := dToS(cToD(subs(VV1->VV1_DTHVAL,1,8)))
			dDatRes := Subs(dDatTmp,7,2) + "/" + Subs(dDatTmp,5,2) + "/" + Subs(dDatTmp,1,4)
			cHorTmp := subs(VV0->VV0_DTHEMI,10)
			if dDataBase > ctod(dDatRes)
				lOk2 := .f.
			Elseif dDataBase > ctod(dDatRes)
				if Time() > cHorTmp
					lOk2 := .f.
				Endif
			Endif
		Endif
	Endif
	
	if lOk2 .and. nOpc <> 2 .and. cParPrg <> "3" .and. Alltrim(VVA->VVA_USUARI) <> Alltrim(Upper(Subs(cUsuario,7,15)))
		dbSelectArea("VVA")
		nRecVVA := Recno()
		dbSeek(xFilial("VVA")+VV1->VV1_NUMTRA)
		cDatS   := dToS(cToD(subs(VV1->VV1_DTHRES,1,8)))
		cDatRes := Subs(cDatS,7,2) + "/" + Subs(cDatS,5,2) + "/" + Subs(cDatS,1,4)
		cMensStr:= OemToAnsi(STR0264) + Alltrim(VVA->VVA_USUARI) + OemToAnsi(STR0265) + cDatRes + OemToAnsi(STR0266) + subs(VV1->VV1_DTHRES,10) + OemToAnsi(STR0267)
		MsgStop(OemToAnsi(cMensStr),OemtoAnsi(STR0015))
		dbGoto(nRecVVA)
		Return .f.
	Endif
Endif

if nOpc == 3
	cSerie := ""
	if !cTipSai == "2"       //Transferencia
		if  M->VVA_VALVDA == 0
			if  M->VVA_CHASSI # Space(25)
				M->VVA_VALVDA := FS_VALVDA()
			Endif
		Endif
		if M->VVA_VALMOV == 0 .and. cTipFat # "2"      //Faturamento Direto
			M->VVA_VALMOV := M->VVA_VALVDA
			cTipFat := VV1->VV1_ESTVEI
		Else
			M->VV1_MODVEI := Space(15)
		Endif
	Endif
	if !Empty(M->VVA_CHASSI)
		if  cTipFat $ "01" .and. !lJaGrv   //Veiculo Novo/Usado
			M->VVA_SEGVIA := VVG->VVG_SEGVIA   //FG_RtDtCV("SGV",VVF->VVF_DATMOV,.t.)
			M->VVA_VALASS := VVG->VVG_VALASS   //FG_RtDtCV("ASS",VVF->VVF_DATMOV,.t.)
			M->VVA_PISENT := VVG->VVG_PISENT
			M->VVA_COFENT := VVG->VVG_COFENT
			M->VVA_CODIND := VVG->VVG_CODIND
			/*
			if Empty(M->VVA_REDCUS)
			M->VVA_REDCUS := VVG->VVG_REDCUS
			Endif
			if Empty(M->VVA_VALREV)
			M->VVA_VALREV := VVG->VVG_VALREV
			Endif
			if Empty(M->VVA_VALREV)
			M->VVA_VALREV := VV2->VV2_VALREV
			Endif
			if Empty(M->VVA_VALFRE)
			M->VVA_VALFRE := VVG->VVG_VALFRE
			Endif
			if Empty(M->VVA_ASSIMP)
			M->VVA_ASSIMP := VVG->VVG_ASSIMP
			Endif
			*/
			
			M->VVA_VCAVEI := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase)
			If Inclui
				M->VVA_VCAVEI := VVG->VVG_VCNVEI
				nCusCorr      := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase)
				nValCorrec    := nCusCorr - M->VVA_VCAVEI
				M->VVA_JUREST := nValCorrec
			Endif
			
			If M->VVA_JUREST == 0
				
				aAreaSF1 := SF1->(Getarea())
				aAreaSE2 := SE2->(Getarea())
				
				SF1->(dbSetOrder(1))
				SF1->(dbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA))
				
				SE2->(dbSetOrder(1))
				if SE2->(dbSeek(xFilial("SE2")+VVF->VVF_SERNFI+VVF->VVF_NUMNFI))
					if SE2->E2_BAIXA # ctod("  /  /  ") .and. (dDataBase - SE2->E2_BAIXA) > 0  //baixado
						//					M->VVA_JUREST := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,"V")
						//					   If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
						//							M->VVA_JUREST := nValCorrec + ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,'V'})
						//						Else
						M->VVA_JUREST := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,"V")
						//						Endif
					elseif SE2->E2_BAIXA = ctod("  /  /  ") //aberto
						M->VVA_JUREST := nValCorrec
					endif
				else // nao encontrei titulo
					//					   If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
					//							M->VVA_JUREST := nValCorrec + ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,'V'})
					//						Else
					M->VVA_JUREST := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,"V")
					//						Endif
				Endif
				SF1->(RestArea(aAreaSF1))
				SE2->(RestArea(aAreaSE2))
			Endif
			
			SD1->(dbSetOrder(1))
			SD1->(dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA))
			
			nNumCarCp := 0
			While !SD1->(Eof()) .And. xFilial('SD1')+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				nNumCarCp += 1
				SD1->(dbSkip())
			EndDo
			M->VVA_VMFVEI := if(!Empty(VVG->VVG_CODIND),FG_CalcMF({ { M->VV0_DATMOV,M->VVA_VCAVEI} }),FG_CalcMF(FG_RetVdCp(VVF->VVF_NUMNFI,VVF->VVF_SERNFI,"E"))/nNumCarCp)
		Else
			M->VVA_VALREV := VV2->VV2_VALREV
			M->VVA_SEGVIA := FG_RtDtCV("SGV","",VVF->VVF_DATMOV,.t.)
			M->VVA_VALASS := FG_RtDtCV("ASS","",VVF->VVF_DATMOV,.t.)
		Endif
	Endif
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	cDesMar := VE1->VE1_DESMAR
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	cDesMod := VV2->VV2_DESMOD
	FG_SEEK("VVO","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+dtos(dDataBase)",1,.T.)
	if Empty(M->VVA_BONFAB)
		nBonus  := VVO->VVO_VALBON
		M->VVA_BONFAB := if(VV1->VV1_ESTVEI=="0" .or. cTipFat == "2",nBonus,0)
	Endif
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	cDesCor := Subs(VVC->VVC_DESCRI,1,19)
	
	nDesCli := 0
	dbSelectArea("VVD")
	dbSetOrder(1)
	if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
		while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
			nDesCli += VVD->VVD_VALOR
			dbSelectArea("VVD")
			dbSkip()
		Enddo
	Endif
	M->VVA_DESCLI := nDesCli
Else
	
	dbSelectArea("VV2")
	dbSetOrder(1)
	dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
	
	//VV2->(dbGoto(Val(VVA->VVA_TRACPA)))
	
	M->VV1_CORVEI := VVA->VVA_CHAINT
	M->VV1_MODVEI := VV2->VV2_MODVEI
	M->VV1_CODMAR := VV2->VV2_CODMAR
	
	M->VVA_VCAVEI := VVA->VVA_VCAVEI
	nValCor  := VVA->VVA_VALMOV - VVA->VVA_VALVDA
	nValSCor := (VVA->VVA_VALMOV - VVA->VVA_VALVDA)+VVA->VVA_VCAVEI
	
	if !lJaGrv
		VVA->(dbSetOrder(1))
		VVA->(dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA))
		VV1->(dbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHAINT))
		cSerie := VV0->VV0_SERNFI
		dDatMov := VV0->VV0_DATMOV
		M->VV0_DATEMI := VV0->VV0_DATEMI
		cTipFat := VV0->VV0_TIPFAT
		if cTipFat == "2" // Faturamento Direto
			cEstoque := "N"
		Else
			if !Inclui
				if Empty(VVA->VVA_CHASSI)
					cEstoque := "N"
				Else
					cEstoque := "S"
				Endif
			Endif
		Endif
		
		cEstCli := VV0->VV0_ESTCLI
		
		//VV0 - Cabecalho
		M->VV0_NUMLIB := VV0->VV0_NUMLIB
		M->VV0_NUMTRA := VV0->VV0_NUMTRA
		M->VV0_CODCLI := VV0->VV0_CODCLI
		M->VV0_LOJA   := VV0->VV0_LOJA
		M->VV0_AUTFAT := VV0->VV0_AUTFAT
		M->VV0_CODAVA := VV0->VV0_CODAVA
		M->VV0_LOJAAV := VV0->VV0_LOJAAV
		M->VV0_CLIALI := VV0->VV0_CLIALI
		M->VV0_LOJALI := VV0->VV0_LOJALI
		M->VV0_AGEFIN := VV0->VV0_AGEFIN
		M->VV0_CODVEN := VV0->VV0_CODVEN
		M->VV0_TIPVEN := VV0->VV0_TIPVEN
		M->VV0_CATVEN := VV0->VV0_CATVEN
		M->VV0_FORPAG := VV0->VV0_FORPAG
		M->VV0_VCARCR := VV0->VV0_VCARCR
		M->VV0_EMPCON := VV0->VV0_EMPCON
		M->VV0_CODGRU := VV0->VV0_CODGRU
		M->VV0_NUMCOT := VV0->VV0_NUMCOT
		M->VV0_NNFFDI := VV0->VV0_NNFFDI
		M->VV0_MODVDA := VV0->VV0_MODVDA
		M->VV0_DPGFAB := VV0->VV0_DPGFAB
		M->VV0_SNFFDI := VV0->VV0_SNFFDI
		if FieldPos('VV0_SDOCFD') > 0
			VV0->VV0_SDOCFD := FGX_UFSNF( VV0->VV0_SNFFDI )
		EndIf
		M->VV0_CODBCO := VV0->VV0_CODBCO
		M->VV0_CODAGE := VV0->VV0_CODAGE
		M->VV0_CODTRA := VV0->VV0_CODTRA
		M->VV0_CLIFTD := VV0->VV0_CLIFTD
		M->VV0_LOJFTD := VV0->VV0_LOJFTD
		M->VV0_DESACE := VV0->VV0_DESACE
		//VVA - Item
		M->VVA_DATRCU := VVA->VVA_DATRCU
		M->VVA_DATDCL := VVA->VVA_DATDCL
		M->VVA_DATBFB := VVA->VVA_DATBFB
		M->VVA_DATRTC := VVA->VVA_DATRTC
		M->VVA_VALMOV := VVA->VVA_VALMOV
		M->VVA_VALCVD := VVA->VVA_VALCVD
		M->VVA_ISSCVD := VVA->VVA_ISSCVD
		M->VVA_VALDES := VVA->VVA_VALDES
		M->VVA_VBAICM := VVA->VVA_VBAICM
		M->VVA_ALIICM := VVA->VVA_ALIICM
		M->VVA_PISENT := VVA->VVA_PISENT
		M->VVA_COFENT := VVA->VVA_COFENT
		M->VVA_CODTES := VVA->VVA_CODTES
		if Empty(VV0->VV0_CODTRA)
			cTransp := "2"
		Else
			cTransp := "1"
		Endif
		
		if !cTipSai == "2"
			M->VVA_VALVDA := VVA->VVA_VALVDA
			M->VVA_VALMOV := VVA->VVA_VALMOV
		Endif
		
		M->VVA_CHASSI := VV1->VV1_CHASSI
		M->VVA_CODIND := VVA->VVA_CODIND
		if !Empty(VV0->VV0_NUMNFI)
			M->VVA_JUREST := VVA->VVA_JUREST
			M->VVA_VCAVEI := VVA->VVA_VCAVEI
		Else
			if cEstoque == "S"
				If Inclui .or. altera
					M->VVA_VCAVEI := VVG->VVG_VCNVEI
					nCusCorr      := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase)
					nValCorrec    := nCusCorr - M->VVA_VCAVEI
					M->VVA_JUREST := nValCorrec
				Endif
				
				If M->VVA_JUREST == 0
					
					aAreaSF1 := SF1->(Getarea())
					aAreaSE2 := SE2->(Getarea())
					
					SF1->(dbSetOrder(1))
					SF1->(dbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA))
					
					SE2->(dbSetOrder(1))
					if SE2->(dbSeek(xFilial("SE2")+VVF->VVF_SERNFI+VVF->VVF_NUMNFI))
						if SE2->E2_BAIXA # ctod("  /  /  ") .and. (dDataBase - SE2->E2_BAIXA) > 0  //baixado
							//						   If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
							//								M->VVA_JUREST := ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,'V'})
							//							Else
							M->VVA_JUREST := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,"V")
							//							Endif
						elseif SE2->E2_BAIXA = ctod("  /  /  ") //aberto
							M->VVA_JUREST := 0
						endif
					else  //nao encontrei o titulo -
						//					   If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
						//							M->VVA_JUREST := ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,'V'})
						//						Else
						M->VVA_JUREST := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,"V")
						//						Endif
					endif
					
					SF1->(RestArea(aAreaSF1))
					SE2->(RestArea(aAreaSE2))
				Endif
				
			Endif
			
		Endif
		
		M->VVA_ACESSO := VVA->VVA_ACESSO
		nCusAce := M->VVA_VCAVEI + M->VVA_ACESSO
		M->VVA_CODTES := VVA->VVA_CODTES
		M->VVA_EMINVD := VVA->VVA_EMINVD
		M->VVA_INPICO := VVA->VVA_INPICO
		M->VVA_INPCRT := VVA->VVA_INPCRT
		M->VVA_INISRT := VVA->VVA_INISRT
		M->VVA_INPCBF := VVA->VVA_INPCBF
		M->VVA_INISBF := VVA->VVA_INISBF
		M->VVA_BONFAB := VVA->VVA_BONFAB
		M->VVA_ALIICM := VVA->VVA_ALIICM
		M->VVA_ICMVEN := VVA->VVA_ICMVEN
		M->VVA_PISRTE := VVA->VVA_PISRTE
		M->VVA_PMFRTE := VVA->VVA_PMFRTE
		M->VVA_ISSRTE := VVA->VVA_ISSRTE
		M->VVA_IMFRTE := VVA->VVA_IMFRTE
		M->VVA_REDCUS := VVA->VVA_REDCUS
		M->VVA_DESCLI := VVA->VVA_DESCLI
		M->VVA_RECTEC := VVA->VVA_RECTEC
		
		M->VVA_SEGVIA := VVA->VVA_SEGVIA
		M->VVA_VALASS := VVA->VVA_VALASS
		M->VVA_VALREV := VVA->VVA_VALREV
		M->VVA_VALFRE := VVA->VVA_VALFRE
		M->VVA_ASSIMP := VVA->VVA_ASSIMP
		
		If cEstoque == "S" .or. cTipfat == "2"
			M->VV1_CODMAR := VV1->VV1_CODMAR
			M->VV1_MODVEI := VV1->VV1_MODVEI
			M->VV1_CORVEI := VV1->VV1_CORVEI
			M->VVA_CHAINT := VVA->VVA_CHAINT
			M->VV1_CHAINT := VV1->VV1_CHAINT
		Else
			M->VVA_CHAINT := Space(6)
			M->VV1_CHAINT := Space(6)
		Endif
		VE1->(dbSetOrder(1))
		VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR))
		cDesMar := VE1->VE1_DESMAR
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
		cDesMod := VV2->VV2_DESMOD
		VVC->(dbSetOrder(1))
		VVC->(dbSeek(xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI))
		cDesCor := Subs(VVC->VVC_DESCRI,1,19)
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
		cDesFpg := alltrim(SE4->E4_DESCRI)
		SA3->(dbSetOrder(1))
		SA3->(dbSeek(xFilial("SA3")+VV0->VV0_CODVEN))
		cNomVen := SA3->A3_NOME
		SA1->(dbSetOrder(1))
		if SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
			cNomCli := SA1->A1_NOME
		Endif
		if SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CLIFTD+VV0->VV0_LOJFTD))
			cNomCFtd:= SA1->A1_NOME
		Endif
		if SA1->(dbSeek(xFilial("SA1")+M->VV0_CODAVA+M->VV0_LOJAAV))
			cNomAva := SA1->A1_NOME
		Endif
		if SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIALI+M->VV0_LOJALI))
			cNomAli := SA1->A1_NOME
		Endif
	Endif
Endif

/*
If FunName() == "VEIVM010" .and. (If(len(aColsIc) == 1,Empty(aColsIc[1,1]),.f.) .or. Len(aColsIc) == 0)
If Altera
M->VVA_BONFAB := VVA->VVA_BONFAB
Else
If !lNlBonus
M->VVA_BONFAB := VV1->VV1_BONFAB
Endif
Endif
M->VVA_DESCLI := 0
cWhile  := .f.
lChassi := .f.
DbSelectArea("VZ5")
dbSetOrder(2)
If DbSeek(xFilial("VZ5")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_CHASSI )
cWhile  := 'VZ5->VZ5_FILIAL+VZ5->VZ5_CHASSI == xFilial("VZ5")+VV1->VV1_CHASSI'
lChassi := .t.
Else
If DbSeek(xFilial("VZ5")+VV1->VV1_CODMAR+VV1->VV1_MODVEI )
cWhile := 'VZ5->VZ5_FILIAL+VZ5->VZ5_MODVEI == xFilial("VZ5")+VV1->VV1_MODVEI'
Endif
Endif

DbSelectArea("VZ7")
DbSetOrder(1)
If !dbSeek(xFilial("VZ7")+M->VV0_NUMTRA)
DbSelectArea("VZ5")
while !eof() .and. &cWhile
lVai := .t.
nTtLen := Len(Alltrim(VZ5->VZ5_OPCION))
for p_ := 1 to nTtLen
cOpcion := subs(VZ5->VZ5_OPCION,p_*3-2,3)
If at(cOpcion,vv1->vv1_opcfab) == 0
lVai := .f.
Endif
Next
If dDataBase >= VZ5->VZ5_DATINI .and. dDataBase <= VZ5->VZ5_DATFIN .and. if(lChassi,If(Empty(VZ5->VZ5_FABMOD),.t.,VV1->VV1_FABMOD == VZ5->VZ5_FABMOD),.t.) .and. lVai .and. If(lChassi,!Empty(VZ5->VZ5_CHASSI),Empty(VZ5->VZ5_CHASSI))
M->VVA_BONFAB += (VZ5->VZ5_BONNAC+VZ5->VZ5_BONREG+VZ5->VZ5_BONCON)
lNlBonus := .t.
If lLevCam .and. !Empty(M->VVA_CHASSI)
DbSelectArea("VZ6")
dbSetOrder(1)
dbSeek(xFilial("VZ6")+VZ5->VZ5_CODACV)
cWhile2 := 'VZ6->VZ6_FILIAL+VZ6->VZ6_CODACV == xFilial("VZ6")+VZ5->VZ5_CODACV'
cAlias2 := "VZ6"
else
If !lLevCam
DbSelectArea("VZ7")
dbSetOrder(2)
dbSeek(xFilial("VZ7")+VZ5->VZ5_CODACV)
cWhile2 := 'VZ7->VZ7_FILIAL+VZ7->VZ7_CODACV == xFilial("VZ7")+VZ5->VZ5_CODACV'
cAlias2 := "VZ7"
Endif
Endif
While !eof() .and. &cWhile2
If lLevCam .and. !Empty(M->VVA_CHASSI)
DbSelectArea("VZ7")
RecLock("VZ7",.t.)
VZ7->VZ7_FILIAL := xFilial("VZ7")
VZ7->VZ7_NUMTRA := M->VV0_NUMTRA
VZ7->VZ7_CODACV := VZ6->VZ6_CODACV
VZ7->VZ7_ITECAM := VZ6->VZ6_ITECAM
VZ7->VZ7_VALITE := VZ6->VZ6_VALITE
MsUnlock()
lLevCam := .t.
Endif
M->VVA_DESCLI += VZ7->VZ7_VALITE
DbSelectArea(cAlias2)
DbSkip()
Enddo
Endif
DbSelectArea("VZ5")
DbSkip()
Enddo
Else
aColsIC:= {}
While !eof() .and. VZ7->VZ7_FILIAL+VZ7->VZ7_NUMTRA == xFilial("VZ7")+M->VV0_NUMTRA
M->VVA_DESCLI += VZ7->VZ7_VALITE
dbskip()
Enddo
Endif

Endif
*/

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TELFATDIR³ Autor ³  Manoel               ³ Data ³ 11/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta Tela de Entrada e Saida no Faturamento Direto           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TELFATDIR()

lEntFDI := .f.

nAliIss    := GETMV("MV_TXISS")  / 100
aEmiNvd  := {OemToAnsi(STR0031),OemToAnsi(STR0030)}

M->VVA_ALIICM := 12
M->VVA_ASSIMP := 0
M->VVA_JUREST := 0
M->VVA_VCAVEI := 0
M->VVA_REDCUS := 0
M->VVA_CODIND := Space(1)

aTransp  := {OemToAnsi(STR0128),OemToAnsi(STR0129)}

Lin  :=   5

cObserv := MSMM(VVA->VVA_OBSMEM,TamSx3("VVA_OBSERV")[1])

@ Lin,004 SAY OemToAnsi(STR0051)  OF oScroll PIXEL COLOR CLR_BLUE
@ Lin,044 MSGET oCodCli VAR M->VV0_CODCLI PICTURE "@9" F3 "VSC" VALID VLD(7) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLUE when lValGeral
@ Lin,144 SAY OemToAnsi(STR0094)  OF oScroll PIXEL COLOR CLR_BLUE
@ Lin,184 MSGET oLojaCli VAR M->VV0_LOJA PICTURE "@9" VALID VLD(18) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
@ Lin,206 SAY oNomCli VAR cNomCli SIZE 70,6 OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0057)  OF oScroll PIXEL COLOR CLR_BLUE //Vendedor
@ Lin,044 MSGET oCodVen VAR M->VV0_CODVEN PICTURE "@E9" F3 "SA3" VALID VLD(15) SIZE 40,4 OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
@ Lin,084 SAY cNomVen OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
@ Lin,144 SAY OemToAnsi(STR0047) OF oScroll PIXEL COLOR CLR_BLUE // TES
@ Lin,184 MSGET oCodtes VAR M->VVA_CODTES PICTURE "@!S3" F3 "SF4" VALID VLD(17) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral

Lin := lin + 11
if cParPrg == "1"
	@  28, 002 TO 158,312 LABEL "" OF oScroll PIXEL
Else
	@  28, 002 TO 147,312 LABEL "" OF oScroll PIXEL
Endif
Lin := lin + 7

//Dados do Veiculo
@ Lin,004 SAY OemToAnsi(STR0088)  OF oScroll PIXEL COLOR CLR_BLUE //Chassi
@ Lin,044 MSGET oChassi VAR M->VVA_CHASSI PICTURE "@!S25" F3 "V1B" VALID VLD(1) SIZE 70,4 OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
@ Lin,144 SAY OemToAnsi(STR0063)  OF oScroll PIXEL COLOR CLR_BLUE //Marca
@ Lin,184 SAY cDesMar OF oScroll PIXEL  COLOR CLR_BLUE FONT oFnt4
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0064) OF oScroll PIXEL COLOR CLR_BLUE //Modelo
@ Lin,044 SAY M->VV1_MODVEI OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
@ Lin,144 SAY  OemToAnsi(STR0065)  OF oScroll PIXEL COLOR CLR_BLUE //Cor
@ Lin,184 SAY oDesCor VAR cDesCor OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0163) OF oScroll PIXEL COLOR CLR_BLUE
@ Lin,044 MSGET oPerDes VAR M->VVA_PERDES PICTURE "@E 99.99" SIZE 38,4 OF oScroll PIXEL COLOR CLR_BLACK When lWhenPD .and. lValGeral
@ Lin,144 SAY OemToAnsi(STR0109) OF oScroll PIXEL COLOR CLR_BLUE //Valor da NF
@ Lin,184 MSGET oValVei VAR M->VVA_VALVDA PICTURE "@E 999,999,999.99" VALID if("SCANIA" $ Upper(cDesMar),FG_CALCVD("V"),.t.) .and. VLD(13) SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0164) OF oScroll PIXEL COLOR CLR_BLACK
@ Lin,044 MSGET oPerCVD VAR M->VVA_PERCVD PICTURE "@E 99.99" VALID FG_CALCVD("P") .and. VLD(13) SIZE 38,4 OF oScroll PIXEL COLOR CLR_BLACK When Empty(VE4->VE4_FDDAFD) .and. lValGeral
@ Lin,144 SAY OemToAnsi(STR0070) OF oScroll PIXEL COLOR CLR_BLUE //Comiss Liquida
@ Lin,184 MSGET oValCvd VAR M->VVA_VALCVD PICTURE "@E 999,999,999.99" VALID if("SCANIA" $ Upper(cDesMar),FG_CALCVD("C"),.t.) .and. VLD(13) SIZE 55,4   OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Lin := lin + 11
@ Lin,004 SAY  OemToAnsi(STR0116) OF oScroll PIXEL COLOR CLR_BLACK //Acessorios
@ Lin,044 MSGET oAcesso VAR M->VVA_ACESSO PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when .f.
@ Lin,144 SAY OemToAnsi(STR0143) OF oScroll PIXEL COLOR CLR_BLACK
@ Lin,184 MSGET oCusAce VAR nCusAce PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when .f.
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0074) OF oScroll PIXEL COLOR CLR_BLACK //Rec.Tecnica
@ Lin,044 MSGET oRecTec VAR M->VVA_RECTEC PICTURE "@E 999,999,999.99" VALID VLD(6) SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral .or. (nOpc == 4 .and. cTipSai == "1" )//Simulacao
@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
@ Lin,184 MSGET oDatRtc VAR M->VVA_DATRTC  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0075) OF oScroll PIXEL COLOR CLR_BLACK //Bonus Fabrica
@ Lin,044 MSGET oBonFab VAR M->VVA_BONFAB PICTURE "@E 999,999,999.99" VALID VLD(28) SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
@ Lin,184 MSGET oDatBfb VAR M->VVA_DATBFB PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0079) OF oScroll PIXEL  COLOR CLR_BLACK //Desp Cliente
@ Lin,044 MSGET oDesCli VAR M->VVA_DESCLI PICTURE "@E 999,999,999.99"  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK When lValGeral
@ Lin,144 SAY  OemToAnsi(STR0144) OF oScroll PIXEL COLOR CLR_BLACK //Data
@ Lin,184 MSGET oDatDCL VAR M->VVA_DATDCL  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0165) OF oScroll PIXEL  COLOR CLR_BLACK
@ Lin,044 MSGET oSegVia VAR M->VVA_SEGVIA PICTURE "@E 999,999,999.99"  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK When lValGeral
@ Lin,144 SAY  OemToAnsi(STR0166) OF oScroll PIXEL COLOR CLR_BLACK //
@ Lin,184 MSGET oValAss VAR M->VVA_VALASS PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Lin := lin + 11
@ Lin,004 SAY OemToAnsi(STR0145) OF oScroll PIXEL  COLOR CLR_BLACK
@ Lin,044 MSGET oValFre VAR M->VVA_VALFRE PICTURE "@E 999,999,999.99"  SIZE 55,4 OF oScroll PIXEL COLOR CLR_BLACK When lValGeral
@ Lin,144 SAY  OemToAnsi(STR0146) OF oScroll PIXEL COLOR CLR_BLACK //
@ Lin,184 MSGET oValRev VAR M->VVA_VALREV PICTURE "@E 999,999,999.99"  SIZE 55,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral

if cParPrg == "2"
	Lin := lin + 15
	@ Lin,004 SAY OemToAnsi(STR0168)  OF oScroll PIXEL COLOR CLR_BLUE // Cliente para Faturar
	@ Lin,044 MSGET oCliFdi VAR M->VV0_CLIFTD PICTURE "@E9" F3 "VSC" VALID VLD(25) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
	@ Lin,084 MSGET oLojaFTD VAR M->VV0_LOJFTD PICTURE "@9" VALID VLD(26) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK
	@ Lin,100 SAY cNomCFtd OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
	@ Lin,144 SAY OemToAnsi(STR0169) OF oScroll PIXEL COLOR CLR_BLUE
	@ Lin,184 MSGET oDatEmi VAR M->VV0_DATEMI PICTURE "@!S3" F3 "SF4" VALID DATAVALIDA(M->VV0_DATEMI) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when  lValGeral
	Lin := lin + 11
	@ Lin,004 SAY OemToAnsi(STR0053)  OF oScroll PIXEL COLOR CLR_BLUE //Categoria da Venda
	@ Lin,044 MSCOMBOBOX oCatVen VAR M->VV0_CATVEN SIZE 40,4 COLOR CLR_BLUE;
	ITEMS aCatVen OF oScroll PIXEL when lValGeral
	@ Lin,144 SAY OemToAnsi(STR0055)  OF oScroll PIXEL COLOR CLR_BLUE //Tipo de Venda
	@ Lin,184 MSGET oTipVen VAR M->VV0_TIPVEN PICTURE "@!" F3 "VV3" VALID VLD(14) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK
	@ Lin,244 SAY cDesTvd OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
	Lin := Lin + 11
	@ Lin,004 SAY OemToAnsi(STR0056) OF oScroll PIXEL COLOR CLR_BLACK //Alienado a
	@ Lin,044 MSGET oCliAli VAR M->VV0_CLIALI PICTURE "@E9" F3 "VSC" VALID VLD(9) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK
	@ Lin,084 MSGET oLojAli VAR M->VV0_LOJALI PICTURE "@9" VALID VLD(22) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK
	//	@ Lin,104 SAY cNomAli OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
	@ Lin,144 SAY OemToAnsi(STR0052)  OF oScroll PIXEL COLOR CLR_BLACK //Avalista
	@ Lin,184 MSGET oCodAva VAR M->VV0_CODAVA PICTURE "@E9" F3 "VSC" VALID VLD(8) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
	@ Lin,224 MSGET oLojaAva VAR M->VV0_LOJAAV PICTURE "@9" VALID VLD(19) SIZE 2,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
	//	@ Lin,244 SAY cNomAva OF oScroll PIXEL COLOR CLR_BLUE FONT oFnt4
	@ Lin,264 BUTTON oObserv PROMPT OemToAnsi(STR0077)  OF oScroll SIZE 43,11 PIXEL  ACTION FS_ObsVei(nOpc) //Observacoes
	Lin := lin + 11
	@ Lin,004 SAY OemToAnsi(STR0170)  OF oScroll PIXEL COLOR CLR_BLUE
	@ Lin,044 MSGET oNNFFDI VAR M->VV0_NNFFDI PICTURE "@E9" VALID(FG_StrZero("M->VV0_NNFFDI",6,.f.))SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
	//	@ Lin,144 SAY OemToAnsi(STR0082)  OF oScroll PIXEL COLOR CLR_BLACK
	@ Lin,084 MSGET oSNFFDI VAR M->VV0_SNFFDI PICTURE "@!!!" SIZE 20,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
	@ Lin,144 SAY OemToAnsi(STR0361)  OF oScroll PIXEL COLOR CLR_BLUE //Modalidade da Venda
	@ Lin,184 MSGET oModVda VAR M->VV0_MODVDA PICTURE "@!" F3 "V4" VALID VLD(29) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK
	Lin := lin + 11
	@ Lin,004 SAY OemToAnsi(STR0362)  OF oScroll PIXEL COLOR CLR_BLUE //Dt Pagto Fab
	@ Lin,044 MSGET oDPgFab VAR M->VV0_DPGFAB PICTURE "@D" SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK
	Lin := lin + 2
Else
	@ Lin,264 BUTTON oObserv PROMPT OemToAnsi(STR0077)  OF oScroll SIZE 43,11 PIXEL  ACTION FS_ObsVei(nOpc) //Observacoes
	Lin := lin + 17
	@ Lin,004 SAY OemToAnsi(STR0047) OF oScroll PIXEL COLOR CLR_BLUE // TES
	@ Lin,044 MSGET oCodtes VAR M->VVA_CODTES PICTURE "@!S3" F3 "SF4" VALID VLD(17) SIZE 40,4  OF oScroll PIXEL COLOR CLR_BLACK when lValGeral
Endif

@ Lin,144 SAY OemToAnsi(STR0149)  OF oScroll PIXEL COLOR CLR_BLACK FONT oFnt5
@ Lin,184 SAY oValMov VAR cMoedCor+" "+tran(M->VVA_VALMOV,"@E 999,999.99")  OF oScroll PIXEL COLOR CLR_HRED FONT oFnt5

if cParPrg == "1"
	@  001, 002 TO 230,312 LABEL "" OF oScroll PIXEL
Else
	@  001, 002 TO 225,312 LABEL "" OF oScroll PIXEL
Endif

oCodCli:SetFocus()

if nOpc == 4
	FS_CARDAD(nOpc)
	nTotEnt := M->VVA_VALCVD
	M->VVA_VALMOV := nTotEnt
	
	If !MaFisFound('NF')
		Return .t.
	Endif
	if  cTipFat == "2"
		FS_FisRef("IT_VALMERC",M->VVA_VALCVD)
		M->VVA_ISSCVD := MaFisRet(,"NF_VALISS")
	Else
		//		FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
		FS_FisRef("IT_VALMERC",M->VVA_VALVDA)
	Endif
	
	FS_FisRef("IT_DESPESA",M->VV0_DESACE)
	FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
	M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	
	if cTipFat == "2" //Faturamento Direto
		M->VVA_VBAICM := 0
		M->VVA_ICMVEN := 0
		M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
		nTotEnt := M->VVA_VALCVD
		M->VVA_VALMOV := nTotEnt
	Else
		M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
		M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		nTotEnt := M->VVA_VALMOV
	Endif
Elseif nOpc == 2
	FS_CARDAD(nOpc)
	nTotEnt := M->VVA_VALCVD
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Ve010Inc ³ Autor ³ Manoel                ³ Data ³ 11/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao de Veiculo qdo Faturamento Comissao Intermediacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 = Chassi                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ve010Inc(cChassi)
Local vv := 0

if Empty(CCHASSI)
	Return .t.
Endif

//Carrega estrutura do VV1 para o cadastro do veiculo quando Faturamento Direto
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV1")
aCampoVV1 := {}
While !Eof().and.(x3_arquivo=="VV1")
	if X3USO(x3_usado).and.cNivel>=x3_nivel .and. !Alltrim(x3_campo) $ "VV1_CHASSI#VV1_CODORI#VV1_ESTVEI#VV1_PROATU#VV1_NOMPRO#VV1_NOMANT#VV1_ENDANT#VV1_CIDANT#VV1_ESTANT#VV1_CEPANT#VV1_DOCIND"
		AADD(aCampoVV1,x3_campo)
	Endif
	dbSkip()
EndDo

dbSelectArea("VV1")
dbSetOrder(2)
cAch := dbSeek(xFilial("VV1")+cCHASSI)

If cAch
	If VV1->VV1_SITVEI == "0"  //Estoque
		If cTipFat <> "2"
			Help(" ",1,"VEJACDM010")
			Return .f.
		Else
			Return .t.
		Endif
	Endif
	dbSelectArea("VV1")
	For vv = 1 to fcount()
		&("M->"+fieldname(VV)) := fieldget(VV)
	Next
	if  !lJaGrv .and. Inclui
		VE4->(dbSetOrder(1))
		VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
		SB1->(dbSetOrder(7))
		if SB1->(dbSeek(xFilial("SB1")+cGruVei+VE4->VE4_CDPRFD))
			if Empty(M->VVA_CODTES)
				M->VVA_CODTES := SB1->B1_TS
			Endif
		Endif
		M->VVA_SEGVIA := FG_RtDtCV("SGV","",M->VV0_DATMOV,.t.)
		M->VVA_VALASS := FG_RtDtCV("ASS","",M->VV0_DATMOV,.t.)
		M->VVA_VALFRE := FG_RtDtCV("FVD","",M->VV0_DATMOV,.t.)
		M->VV0_CLIFTD := VE4->VE4_CODFAB
		M->VV0_LOJFTD := VE4->VE4_LOJA
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIFTD+M->VV0_LOJFTD))
		cNomCFtd:= SA1->A1_NOME
		if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
			M->VVA_EMINVD := "1"
		Else
			M->VVA_EMINVD := "0"
		Endif
	Endif
	
	dbSelectArea("VV1")
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR))
	cDesMar := VE1->VE1_DESMAR
	VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
	cDesMod := VV2->VV2_DESMOD
	FG_SEEK("VVO","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+dtos(dDataBase)",1,.T.)
	nBonus  := VVO->VVO_VALBON
	M->VVA_BONFAB := if(VV1->VV1_ESTVEI=="0" .or. cTipFat == "2",nBonus,0)
	M->VVA_VALREV := VV2->VV2_VALREV
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI))
	cDesCor := Subs(VVC->VVC_DESCRI,1,19)
	M->VVA_CHAINT := VV1->VV1_CHAINT
	
	dbSelectArea("VV0")
	if !Empty(VE4->VE4_FDDAFD)
		lWhenPD := .t.
		FG_FORMULA(VE4->VE4_FDDAFD)
	Else
		lWhenPD := .f.
	Endif
	Return .t.
Else
	if cTipFat == "2"
		aTELA := aGETS:= {}
		cAlias:="VV1"
		dbSelectArea("VV1")
		aMemos   := {{"VV1_OBSMEM","VV1_OBSERV"}}
		nOpcaRET := AxInclui(cAlias,nReg,nOpc,aCampoVV1,"GRVVV1",,)
		aMemos   := {{"VVA_OBSMEM","VVA_OBSERV"}}
		
		If nOpcaRET == 1
			dbSelectArea("VV1")
			For vv = 1 to fcount()
				&("M->"+fieldname(VV)) := fieldget(VV)
			Next
			if  !lJaGrv .and. Inclui
				VE4->(dbSetOrder(1))
				VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
				SB1->(dbSetOrder(7))
				if SB1->(dbSeek(xFilial("SB1")+cGruVei+VE4->VE4_CDPRFD))
					if Empty(M->VVA_CODTES)
						M->VVA_CODTES := SB1->B1_TS
					Endif
				Endif
				M->VVA_SEGVIA := FG_RtDtCV("SGV","",M->VV0_DATMOV,.t.)
				M->VVA_VALASS := FG_RtDtCV("ASS","",M->VV0_DATMOV,.t.)
				M->VVA_VALFRE := FG_RtDtCV("FVD","",M->VV0_DATMOV,.t.)
				M->VV0_CLIFTD := VE4->VE4_CODFAB
				M->VV0_LOJFTD := VE4->VE4_LOJA
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+M->VV0_CLIFTD+M->VV0_LOJFTD))
				cNomCFtd:= SA1->A1_NOME
				if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
					M->VVA_EMINVD := "1"
				Else
					M->VVA_EMINVD := "0"
				Endif
			Endif
			
			VE1->(dbSetOrder(1))
			VE1->(dbSeek(xFilial("VE1")+M->VV1_CODMAR))
			cDesMar := VE1->VE1_DESMAR
			VV2->(dbSetOrder(1))
			VV2->(dbSeek(xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI))
			cDesMod := VV2->VV2_DESMOD
			FG_SEEK("VVO","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+dtos(dDataBase)",1,.T.)
			nBonus  := VVO->VVO_VALBON
			M->VVA_BONFAB := if(VV1->VV1_ESTVEI=="0" .or. cTipFat == "2",nBonus,0)
			M->VVA_VALREV := VV2->VV2_VALREV
			VVC->(dbSetOrder(1))
			VVC->(dbSeek(xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI))
			cDesCor := Subs(VVC->VVC_DESCRI,1,19)
			M->VVA_CHAINT := VV1->VV1_CHAINT
			
			dbSelectArea("VV0")
			if !Empty(VE4->VE4_FDDAFD) // Tem dados Adicionais
				lWhenPD := .t.
				FG_FORMULA(VE4->VE4_FDDAFD)  // FS_FDSCANIA()
			Else
				lWhenPD := .f.
			Endif
			Return .t.
		EndIf
	Else
		Help(" ",1,"VENCDM010")
		Return .f.
	Endif
Endif


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GRVVV1   ³ Autor ³ Manoel                ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao de campos do VV1                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRVVV1()

M->VV1_CHASSI := M->VVA_CHASSI
M->VV1_ESTVEI := cNovUsa
M->VV1_CODORI := "0"  //Fabrica

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EnBr010a     ³ Autor ³ Manoel                ³ Data ³ 13/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EnBr010a(oDlg,bOk1,bCancel)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtCan, oBtCVei, oBtPrtFic, oBtVdaSim, oBtParc, oBtOK
Local lVolta :=.f.
lVok := .f.
if Type("cTipSai") == "U"
	cTipSai := "99"
Endif
if Type("cSimVda") == "U"
	cSimVda := "V"
Endif

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlgVV

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP STR0067  //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP STR0069  //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP STR0071  //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0181  //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP STR0073  //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP OemToAnsi(STR0080)  //"Gerenciador de ImpressÆo..."

DEFINE BUTTON oBtPrtFic RESOURCE "IMPRESSAO"  OF oBar ACTION (nopca:=0,FG_PrtFic()) TOOLTIP STR0089

oBar:nGroups += 6

DEFINE BUTTON oBtCan RESOURCE STR0059 OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0061
SetKEY(24,oBtCan:bAction)

oDlgVV:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return(Nil)


Static Function ButtonOff(bSet15,bSet24,lOk)
DEFAULT lOk := .t.
if lOk
	SetKey(15,bSet15)
	SetKey(24,bSet24)
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_EQPINS    ³ Autor ³ Manoel                ³ Data ³ 13/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre Tela de Acessorios para o Veiculo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EQPINS(nOpc)

Local aHeaderE      := aClone(aHeader)
Local aColsE        := aClone(aCols)
Local bCampo        := { |nCPO| Field(nCPO) }
Local lRet, nOpca6  := 0,cSaveMenuh,oDlg
Local nLin := 001
Local _ni := 0

nOpcE   := 2
nOpcG   := 3
nOpcEs  := nOpcE
nOpcGs  := nOpcG
nValEqp := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoEq:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVT")
aHeaderEq:={}
While !Eof().And.(x3_arquivo=="VVT")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !Alltrim(x3_campo) $ [VVT_CHAINT/VVT_DESGRU/VVT_NUMTRA/VVT_ATIVSN]
		nUsadoEq:=nUsadoEq+1
		Aadd(aHeaderEq,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		wVar  := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
End

dbSelectArea("VVT")
dbSetOrder(2)
Set softseek off
zz := dbSeek(xFilial("VVT")+M->VV0_NUMTRA)
if M->VV1_CHAINT # VVT->VVT_CHAINT
	zz := .f.
Endif
if nOpcG == 3 .and. !zz
	aColsEq:={}
	aColsEq:={Array(nUsadoEq+1)}
	aColsEq[1,nUsadoEq+1]:=.F.
	For _ni:=1 to nUsadoEq
		aColsEq[1,_ni]:=CriaVar(aHeaderEq[_ni,2])
	Next
Else
	aColsEq:={}
	dbSelectArea("VVT")
	While VVT->VVT_NUMTRA == M->VV0_NUMTRA .and. !eof() .and. VVT->VVT_FILIAL == xFilial("VVT")
		AADD(aColsEq,Array(nUsadoEq+1))
		For _ni:=1 to nUsadoEq
			aColsEq[Len(aColsEq),_ni]:=If(aHeaderEq[_ni,10] # "V",FieldGet(FieldPos(aHeaderEq[_ni,2])),CriaVar(aHeaderEq[_ni,2]))
		Next
		aColsEq[Len(aColsEq),nUsadoEq+1]:=.F.
		nValEqp += VVT->VVT_VALEQP
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xfilial("SB1")+aColsEq[Len(aColsEq),FG_POSVAR('VVT_GRUITE',"aHeaderEq")]+aColsEq[Len(aColsEq),FG_POSVAR('VVT_CODITE',"aHeaderEq")])
		aColsEq[len(aColsEq),FG_POSVAR("VVT_DESITE","aHeaderEq")] := SB1->B1_DESC
		dbSelectarea("VVT")
		dbSkip()
	Enddo
Endif

dbSelectArea("VVT")
dbSetOrder(1)

cAliasGetD6 := "VVT"
cAlias2     := "VVT"

If Type("aColsIC[1,1]")!="U".and.Empty(aColsIC[1,1]).or.len(aColsIC) == 0
	/*
	///////////////////////////////////////////
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados dos Itens de Campanha       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsadoIC:=0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VZ7")
	aHeaderIC:={}
	While !Eof().And.(x3_arquivo=="VZ7")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ [VZ7_CODACV/VZ7_ITECAM/VZ7_VALITE]
	nUsadoIC:=nUsadoIC+1
	Aadd(aHeaderIC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal,x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	wVar  := "M->"+x3_campo
	&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
	Enddo
	
	aColsIC:={}
	aColsIC:={Array(nUsadoIC+1)}
	aColsIC[1,nUsadoIC+1]:=.F.
	For _ni:=1 to nUsadoIC
	aColsIC[1,_ni]:=CriaVar(aHeaderIC[_ni,2])
	Next
	*/
Endif

dbSelectArea("VVT")
dbSetOrder(1)

cAliasGetD7 := "VZ7"
cAlias7     := "VZ7"

If Len(aColsEq)>0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo6    :=OemToAnsi(STR0001)
	cAliasEnch6 :="VV1"
	cLinOk6     :="FG_OBRIGAT"
	cTudoOk6    :="AllwaysTrue()"
	cFieldOk6   :="FG_MEMVAR(),FS_ATUACESS()"
	
	Private oBar3, lok3, obtok3
	aAltEnchoice := {}
	Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	nPosAnt:=9999,      nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
	
	nOpcE    := If(nOpcE==Nil,3,nOpcE)
	nOpcG    := If(nOpcG==Nil,3,nOpcG)
	lVirtual := .f.
	nLinhas  := 99
	
	nLin := 002
	
	@ nLin,004 SAY OemToAnsi(STR0064)        SIZE 40,08 OF oFolderV:aDialogs[3] PIXEL COLOR CLR_BLACK FONT oFnt4    //Modelo
	@ nLin,038 SAY oModelo VAR M->VV1_MODVEI SIZE 55,08 OF oFolderV:aDialogs[3] PIXEL COLOR CLR_BLUE  FONT oFnt4
	
	@ nLin,114 SAY OemToAnsi(STR0065)     SIZE 40,08 OF oFolderV:aDialogs[3] PIXEL COLOR CLR_BLACK FONT oFnt4
	@ nLin,137 SAY Subs(cDesCor,1,16)    SIZE 40,08 OF oFolderV:aDialogs[3] PIXEL COLOR CLR_BLUE  FONT oFnt4
	
	aHeader  := aClone(aHeaderEq)
	aCols    := aClone(aColsEq)
	oGetDados:= MsGetDados():New(01,1,112,315,nOpcG,cLinOk6,cTudoOk6,"",.T.,,,,,cFieldOk6,,,,oFolder2:aDialogs[1])
	oGetDados:oBrowse:default()
	oGetDados:oBrowse:bDelete      := {|| FS_ATUACESS(.t.), if(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.), oGetDados:oBrowse:Refresh() }
	oGetDados:oBrowse:bGotFocus    := {|| aCols  :=aClone(aColsEq), aHeader  :=aClone(aHeaderEq), n  :=nEq, oGetDados:oBrowse:SetFocus()}
	oGetDados:oBrowse:bLostFocus   := {|| aColsEq:=aClone(aCols)  , aHeaderEq:=aClone(aHeader)  , nEq:=n}
	aHeader  := aClone(aHeaderE)
	aCols    := aClone(aColsE)
	
	@ 114,001 LISTBOX oLbxSerie FIELDS HEADER  OemToAnsi(STR0363);  //Equipamentos de Serie
	COLSIZES 180 SIZE 156,074 OF oFolder2:aDialogs[1] PIXEL ON DBLCLICK(FS_CHILDSER(oLbxSerie:nAt))
	oLbxSerie:SetArray(aSerie)
	oLbxSerie:bLine := { || { aSerie[oLbxSerie:nAt,02] }}
	
	@ 114,158 LISTBOX oLbxOpc FIELDS HEADER  OemToAnsi(STR0364),OemToAnsi(STR0365),OemToAnsi(STR0366);//Opcionais - Qtdade - Estoque
	COLSIZES 105,020,040 SIZE 157,074 OF oFolder2:aDialogs[1] PIXEL ON DBLCLICK(FS_CHILDOPC(oLbxOpc:nAt))
	oLbxOpc:SetArray(aOpc)
	oLbxOpc:bLine := { || { aOpc[oLbxOpc:nAt,02] ,;
	aOpc[oLbxOpc:nAt,03] ,;
	aOpc[oLbxOpc:nAt,04] }}
	
	/*
	aHeader  := aClone(aHeaderIC)
	aCols    := aClone(aColsIC)
	oGetDadosIC:= MsGetDados():New(01,1,182,315,nOpcG,cLinOk6,cTudoOk6,"",.T.,,,,,'Fs_TraItCam("A")',,,,oFolder2:aDialogs[2])
	oGetDadosIC:oBrowse:default()
	oGetDadosIC:oBrowse:bChange      := {|| Fs_TraItCam("A"), oGetDadosIC:oBrowse:Refresh()  }
	oGetDadosIC:oBrowse:bDelete      := {|| Fs_TraItCam("D"),if(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.), oGetDadosIC:oBrowse:Refresh() }
	oGetDadosIC:oBrowse:bGotFocus    := {|| aCols  :=aClone(aColsIC), aHeader  :=aClone(aHeaderIC), n  :=nIC, oGetDadosIC:oBrowse:SetFocus()}
	oGetDadosIC:oBrowse:bLostFocus   := {|| aColsIC:=aClone(aCols)  , aHeaderIC:=aClone(aHeader)  , nIC:=n}
	aHeader  := aClone(aHeaderIC)
	aCols    := aClone(aColsIC)
	*/
	
Endif

nOpcE := nOpcEs
nOpcG := nOpcGs

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VDRVM010³ Autor ³ Manoel                ³ Data ³ 04/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria vetor p/ ser usado na FG_CalcVlrs (Demonstr. Resultado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FS_VDRVM010                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VDRVM010(cTipFat,cCodMap)

aStru   := {}

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)

dbSelectArea("VS5")
dbSetOrder(1)
dbSeek(xFilial("VS5")+cCodMap)

dbSelectArea("VOQ")
dbSetOrder(1)
dbSeek(xFilial("VOQ")+cCodMap)

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
	
	if !(cTipFat $ VOQ_TIPFAT)
		dbSkip()
		Loop
	Endif
	If VOQ_INDATI # "1" // Sim
		dbSkip()
		Loop
	Endif
	If VOQ_CODMAP # cCodMap
		exit
	Endif
	
	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
	aadd(aStru,{ M->VV0_NUMTRA,VV1->VV1_TRACPA,SB1->B1_COD,;
	VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,M->VV0_DATMOV,0,0,VOQ_CTATOT})
	
	dbSkip()
	
Enddo

Return(aStru)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FISREF      ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Chama a MaFisRef da Microsiga                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FISREF(cReferencia,xValor)

Local aArea	:= GetArea()

//if Type('cEstoque') == "U" .or. cEstoque == "S"
If !MaFisFound("IT",1)
	MaFisAdd("",M->VV0_CODTES,0,0,0,CriaVar("D2_NFORI"),CriaVar("D2_SERIORI"),,0,0,0,0,0)
	MaFisAlt(cReferencia,xValor,1)
Endif

If MaFisFound("NF")
	MaFisAlt(cReferencia,xValor,1)
EndIf
//Endif

RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GRMODVEI    ³ Autor ³  Manoel          ³ Data   24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna Codigos de Modelo de Veiculos pertencentes ao Grupo ³±±
±±³          ³de Modelo Informado no Parametro                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRMODVEI(cGruMod)

Local nSavRecno
Local cRet      := ""
Local cSavAlias := Alias()
Local aGrupos   := {}

dbSelectArea("VVR")
dbSetOrder(1)
if dbSeek(xFilial("VVR")+cCODMAR+SPACE(TamSx3("VV1_CODMAR")[1]-len(cCODMAR))+cGruMod)
	while !EOF() .and. alltrim(VVR->VVR_DESCRI) == cGruMod
		aadd(aGrupos,VVR->VVR_GRUMOD)
		dbSkip()
	EndDo
Endif

dbSelectArea("VV2")
nSavRecno := Recno()
dbSetOrder(3)
dbSeek(xFilial("VV2")+cCODMAR)
While !eof() .and. VV2->VV2_FILIAL == xFilial("VV2") .and. alltrim(VV2->VV2_CODMAR) == cCODMAR
	if ascan(aGrupos,alltrim(VV2->VV2_GRUMOD)) > 0
		if cRet <> ""
			cRet := cRet + "/"
		Endif
		cRet := cRet + alltrim(VV2->VV2_MODVEI)
	Endif
	dbSelectArea("VV2")
	dbSkip()
Enddo

dbGoTo(nSavRecno)
dbSelectArea(cSavAlias)

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GrCorVei    ³ Autor ³  Manoel          ³ Data   24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Codigos de Cores  de Veiculos pertencentes ao Grupo³±±
±±³          ³ de Cor Informado no Parametro                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GrCorVei(cGruCor)

cRet := ""

cSavAlias := alias()
dbSelectArea("VVC")
nSavRecno := Recno()
dbSeek(xFilial("VVC"))

While !eof() .and. VVC->VVC_FILIAL == xFilial("VVC")
	If VVC->VVC_GRUCOR == cGruCor .and. If(!empty(cTipCor),VVC->VVC_TIPCOR == Subs(cTipCor,1,1),.t.)
		cRet := cRet + VVC->VVC_CORVEI
	Endif
	dbSkip()
Enddo

dbGoTo(nSavRecno)

dbSelectArea(cSavAlias)

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FilCor      ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtro da Consulta COR no SXB                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILCOR()

cFilt := ""

if !Empty(cCODMAR)
	cFilt := "VVC->VVC_CODMAR == cCODMAR"
Endif

if !Empty(cGruCor)
	cFilt := cFIlt + " .and. " + "VVC->VVC_GRUCOR == cGruCor"
Endif

if !Empty(cTipCor)
	cFilt := cFIlt + " .and. " + "VVC->VVC_TIPCOR == Subs(cTipCor,1,1)"
Endif

if Subs(cFilt,2,5) ==  ".and."
	cFilt := Subs(cFilt,8)
Endif

If Empty(cFilt)
	cFilt := ".t."
Endif

Return(&cFilt)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FilMod      ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtro da Consulta MOD no SXB                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILMOD()

cFilt := ""

if !Empty(cCODMAR)
	cFilt := "VV2->VV2_CODMAR == cCODMAR"
Endif

if !Empty(cGruMod)
	cFilt := cFIlt + " .and. " + "VV2->VV2_GRUMOD == cGruMod"
Endif

if Subs(cFilt,2,5) ==  ".and."
	cFilt := Subs(cFilt,8)
Endif

If Empty(cFilt)
	cFilt := ".t."
Endif

Return(&cFilt)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_MarcVei     ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Marca no ListBox do Filtro, o Veiculo escolhido e carrega   ³±±
±±³          ³variaveis necessarias                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MarcVei()

Local cSavAlias := Alias()
Local bCampo1   := { |nCPO| FieldName(nCPO) }
Local i := 0

if aStruVV1[oLbox:nAt,2] == "R"
	MsgInfo(STR0367,STR0015) //Veiculo de Remessa..., Somente para consulta! - Atencao !
	Return .t.
Endif
if aStruVV1[oLbox:nAt,2] == "C"
	MsgInfo(STR0368,STR0015) //Veiculo de Consignacao..., Somente para consulta! - Atencao !
	Return .t.
Endif

If aStruVV1[oLbox:nAt,1] == .f.
	aStruVV1[oLbox:nAt,1] := .t.
	
	M->VVA_CHASSI  := aStruVV1[oLbox:nAt,5]
	M->VV0_CHASSI  := aStruVV1[oLbox:nAt,5]
	VLD(1)
	
	dbSelectArea(cSavAlias)
	
	cTipFat  := Subs(aStruVV1[oLbox:nAt,10],16,1)
	M->VVA_VALVDA :=aStruVV1[oLbox:nAt,9]
	M->VVA_VALMOV :=aStruVV1[oLbox:nAt,9]
	M->VV0_VALMOV :=aStruVV1[oLbox:nAt,9]
	M->VV0_VALTOT :=aStruVV1[oLbox:nAt,9]
	
	lOk2 := .f.
	if VV1->VV1_RESERV $ "1/3" // 1 reservado 3 venda futura
		lOk2 := .t.
		if !Empty(VV1->VV1_DTHVAL)
			dDatTmp := dToS(cToD(subs(VV1->VV1_DTHVAL,1,8)))
			dDatRes := Subs(dDatTmp,7,2) + "/" + Subs(dDatTmp,5,2) + "/" + Subs(dDatTmp,1,4)
			cHorTmp := subs(VV0->VV0_DTHEMI,10)
			if dDataBase > ctod(dDatRes)
				lOk2 := .f.
			Elseif dDataBase > ctod(dDatRes)
				if Time() > cHorTmp
					lOk2 := .f.
				Endif
			Endif
		Endif
	Endif
	
	if lOk2
		aStruVV1[oLbox:nAt,1] := .f.
	Else
		FS_CARDAD(3)
	Endif
Else
	M->VVA_CHASSI  := Space(25)
	M->VVA_CHAINT  := Space(06)
	M->VV1_CODMAR  := Space(3)
	M->VV1_MODVEI  := Space(30)
	M->VV1_CORVEI  := Space(6)
	M->VVA_VALVDA  := 0
	M->VVA_VALMOV  := 0
	M->VV0_TIPFAT  := Space(01)
	cTipFat         := Space(01)
	aStruVV1[oLbox:nAt,1] := .f.
Endif

For i = 1 to len(aStruVV1)
	If aStruVV1[i,1] == .t. .and. i # oLBox:nat
		aStruVV1[i,1] := .f.
	Endif
Next

oLbox:SetArray(aStruVV1)
oLbox:bLine := { || { if(aStruVV1[oLbox:nAt,01] == .f.,oNo,oTik),;
iif(aStruVV1[oLbox:nAt,02] == "N",oNo,fs_corbrowse(oLbox:nAt)),;
iif(aStruVV1[oLbox:nAt,03] == .f.,oNada,oFoto),;
aStruVV1[oLbox:nAt,04],;
aStruVV1[oLbox:nAt,05],;
aStruVV1[oLbox:nAt,06],;
aStruVV1[oLbox:nAt,07],;
aStruVV1[oLbox:nAt,08],;
Fg_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"9,999,999.99")),;
aStruVV1[oLbox:nAt,10],;
aStruVV1[oLbox:nAt,11],;
aStruVV1[oLbox:nAt,12],;
aStruVV1[oLbox:nAt,13],;
aStruVV1[oLbox:nAt,14]} }

cNovUsa := cTipFat

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDAFPGS    ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda Forma de Pagamento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function FS_MUDAFPGS()

Local wRet := .t.

if Type("lTroca") <> "U" .and. lTroca
Return .t.
Endif

dbSelectArea("SE4")
dbSeek(xFilial("SE4"))
if dbSeek(xFilial("SE4")+cTipPag)
cDesPag := SE4->E4_DESCRI
M->VV0_FORPAG := cTipPag
cDesFpg := cDesPag
SE4->(dbSetOrder(1))
if SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
if val(AllTrim(SE4->E4_COND)) > 0
FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,"cTipPag",nTotEnt)
Else
FG_DesfPag()
cCondic1:=ctod(" ")
cCondic2:=space(02)
cCondic3:=space(02)
cCondic4:=space(02)
Endif
Endif

Else
wRet := .f.
Endif

oDesPag:Refresh()

Return(wRet)
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDAABA     ³ Autor ³ Andre            ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Efetua a validacao para a entrada em cada ABA dos Folders   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1 = "V" (Venda/Simulacao)                                   ³±±
±±³          |2 = "T" (Transferencia)                                     ³±±
±±³          |3 = "R" (Remessa)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MUDAABA(cPar,x,nOpc)

Local lRet := .t.

if cTipFat == "2"  //Faturamento Direto
	cNovUsa := "0"  //Veiculo Novo
Else
	cNovUsa := cTipFat
Endif

If cEstoque == "N" //Nao Estoque
	lWhenCus := nOpc == 3 .or. nOpc == 4
Else
	lWhenCus := VV1->VV1_INDCAL == "5"  //Veiculos Pedidos a Fabrica
Endif

if  cPar == "V"
	if x == 1
		if cTipFat == "2" .or. (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") .or. nOpc == 2
			lRet := .f.
		Endif
	Elseif x == 3 .or. x == 4
		if !Empty(M->VV0_CODCLI) .and. !Empty(M->VVA_CODTES) .and. !Empty(M->VVA_CHASSI)
			lRet := .t.
		Else
			lRet := .f.
		Endif
	Endif
Elseif cPar $"TR"
	if oFolderV:noption == 1
		lRet := FS_REMTRA(cAlias, nReg, nOpc) //3rd Valdir
	Endif
Endif

if x == 3
	aSerie := {}
	aOpc   := {}
	
	dbSelectarea("VVM")
	dbSeek(xFilial("VVM")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
	While !Eof() .and. xFilial("VVM") == VVM->VVM_FILIAL .and. VVM->VVM_MODVEI == VV1->VV1_MODVEI
		dbSelectarea("VVW")
		dbSeek(xFilial("VVW")+VV1->VV1_CODMAR+VVM->VVM_CODOPC)
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+VVW->VVW_GRUITE+VVW->VVW_CODITE)
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei)
		nSaldo := SaldoSb2()
		
		if VVW->VVW_OPCSER == "1"
			aadd(aSerie,{VVW->VVW_CODOPC,VVW->VVW_DESOPC})
		Else
			aadd(aOpc,{VVW->VVW_CODOPC,VVW->VVW_DESOPC,VVM->VVM_QTDPEC,nSaldo})
		Endif
		
		dbSelectArea("VVM")
		dbSkip()
	EndDo
	
	if Len(aSerie) == 0
		aSerie := {{"",""}}
	Endif
	
	if Len(aOpc) == 0
		aOpc   := {{"","",0,0}}
	Endif
	
	oLbxSerie:SetArray(aSerie)
	oLbxSerie:bLine := { || { aSerie[oLbxSerie:nAt,02] }}
	olbxSerie:Refresh()
	
	oLbxOpc:SetArray(aOpc)
	oLbxOpc:bLine := { || { aOpc[oLbxOpc:nAt,02] ,;
	aOpc[oLbxOpc:nAt,03] ,;
	aOpc[oLbxOpc:nAt,04] }}
	olbxOpc:Refresh()
Endif

if x == 3 .or. x == 4
	if !Empty(M->VVA_CHASSI) .and. cTipFat # "2"  //Faturamento Direto
		if !VLD(1,.f.)
			lRet := .f.
		Endif
	Endif
	
	M->VVA_VALMOV := M->VV0_VALMOV
	nTotEnt := M->VVA_VALMOV
	
Endif

if x == 4
	FG_TOTENT()
Endif

if oFolderV:nOption==5
	oFolderV:nOption := nAbaAnt
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GRCDPG10    ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava Condicao de Pagamento                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRCDPG10()

Local ix1        := 0
Local nCont      := 0
Local lCria      := .t.
Local lDiferen   := .f.
Local nContaCols := 0
Local cComparSE1 := ""
Local cNumTit    := ""
Local cTipCob    := if(!Empty(cCodBco).or.!Empty(VV0->VV0_CODBCO),"1","0")
Local xy_,i,i_	 := 0

dbSelectArea("SF4")
dbSetOrder(1)
if dbSeek(xFilial("SF4")+VVA->VVA_CODTES)
	if SF4->F4_DUPLIC == "N"
		Return
	Endif
Endif

IncProc(STR0237)

If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0238),OemToAnsi(STR0199))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .F.
	EndIf
EndIf

if !lTroca
	SE4->(dbSetOrder(1))
	if SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG)) .and.  Iif(Len(aIteParc) > 0 ,Empty(aIteParc[1,1]),.T.)
		if val(AllTrim(SE4->E4_COND)) > 0 .and. M->VV0_TIPFAT # "2"
			FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,"VV0_FORPAG",nTotEnt)
		Else
			FG_DesfPag()
			cCondic1:=ctod(" ")
			cCondic2:=space(02)
			cCondic3:=space(02)
			cCondic4:=space(02)
		Endif
	Endif
Endif

if (Len(aColsC) = 1) .and. (Empty(aColsC[1,1])) .and. (Empty(aIteParc[1,1])) .and. !lTroco
	aColsC[Len(aColsC),1] := "DP"
	aColsC[Len(aColsC),2] := "DUPLICATA"
	aColsC[Len(aColsC),3] := dDataBase
	aColsC[Len(aColsC),4] := nTotEnt
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(xFilial("VE4")))
	while SE4->E4_FILIAL == xFilial("SE4") .and. SE4->(!Eof())
		if SE4->E4_TIPO # "A" .and. Alltrim(SE4->E4_COND) == "0"
			M->VV0_FORPAG := SE4->E4_CODIGO
			Exit
		Endif
		SE4->(dbSkip())
	Enddo
Endif


// Quando as parcelas foram geradas antes da venda
// as mesmas serao convertidas p/ a data base do sistema.
For xy_:=1 to Len(aColsC)
	if aColsC[xy_,FG_POSVAR('VS9_DATPAG',"aHeaderC")] < dDataBase
		aColsC[xy_,FG_POSVAR('VS9_DATPAG',"aHeaderC")] := dDataBase
	Endif
Next

For xy_:=1 to Len(aIteParc)
	if aIteParc[xy_,1] < dDataBase
		aIteParc[xy_,1] := dDataBase
	Endif
Next

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if VE4->VE4_GTPRFT  == "0" // Gera titulo na Proposta
	cNumTit := Right(M->VV0_NUMTRA,9)
	cPrefNF := "PRP"
Else  // Gera titulo no Faturamento
	cNumTit := cNota
Endif

if !Inclui
	// Gera titulo no faturamento e estou no faturamento  ou   Gera titulo na proposta e estou na proposta
	if (VE4->VE4_GTPRFT  == "1" .and. (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")) .or. (VE4->VE4_GTPRFT  == "0" .and. cParPrg == "2") .or. (VV1->VV1_CODMAR <> VE4->VE4_PREFAB)
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial('SE1')+cPrefNF+cNumTit))
			aParcelas := {}
			while ! Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == cNumTit
				AADD(aParcelas,{{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
				{"E1_NUM"     ,E1_NUM     ,nil},;
				{"E1_PARCELA" ,E1_PARCELA ,nil},;
				{"E1_TIPO"    ,E1_TIPO    ,nil},;
				{"E1_NATUREZA",E1_NATUREZA,nil},;
				{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
				{"E1_LOJA"    ,E1_LOJA    ,nil},;
				{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
				{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
				{"E1_VENCREA" ,E1_VENCREA ,nil},;
				{"E1_VALOR"   ,E1_VALOR   ,nil},;
				{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
				{"E1_DATABOR" ,E1_DATABOR ,Nil},;
				{"E1_PORTADO" ,E1_PORTADO ,Nil},;
				{"E1_SITUACA" ,E1_SITUACA ,Nil},; 
				{"E1_ORIGEM" , "MATA460"  ,nil}})
				dbSelectArea("SE1")
				dbSkip()
			Enddo
			pergunte("FIN040",.F.)
			For i = 1 to len(aParcelas)
				MSExecAuto({|x,y| FINA040(x,y)},aParcelas[i],5)
				if lMsErroAuto
					DisarmTransaction()
					Break
				Endif
			Next
		Endif
	Endif
Endif

if Empty(cCodBco)
	cCodBco := GetMv("MV_BCOCXA")
Endif
FG_Seek("SA6","cCodBco",1,.f.)
if SA6->A6_BORD == "0"
	cNumBord := "BCO"+SA6->A6_COD
	dDatBord := dDataBase
Endif

cNumBord2 := ""
dDatBord2 := cTod("")

nCont := 0
For ix1 :=1 to len(aColsC)
	aParcelas := {}
	
	if Empty(aColsC[ix1,1]) .or. aColsC[ix1,Len(aColsC[ix1])]
		Loop
	Endif
	
	cCodBco2 := cCodBco
	if !Empty(aColsC[iX1,FG_POSVAR('VS9_PORTAD',"aHeaderC")])
		cCodBco2 := aColsC[iX1,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
	Endif
	FG_Seek("SA6","cCodBco2",1,.f.)
	if SA6->A6_BORD == "0"
		cNumBord2 := "BCO"+SA6->A6_COD
		dDatBord2 := dDataBase
	Endif
	
	nCont++
	if TamSx3("E1_PARCELA")[1] == 1
		cParcela := ConvPN2PC(ncont)
	Else
		//								cParcela := Soma1( ALLTRIM(str(ncont-1)) )
		cParcela := Soma1( strZERO(ncont-1,TamSx3("E1_PARCELA")[1]) )
	Endif
	
	aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                  ,nil})
	aAdd(aParcelas,{"E1_NUM"     , cNumTit                  ,nil})
	aAdd(aParcelas,{"E1_PARCELA" , cParcela                 ,nil})
	aAdd(aParcelas,{"E1_TIPO"    , aColsC[ix1,1]            ,nil})
	aAdd(aParcelas,{"E1_NATUREZA", SA1->A1_NATUREZ          ,nil})
	aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD              ,nil})
	aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA             ,nil})
	aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                ,nil})
	aAdd(aParcelas,{"E1_VENCTO"  , aColsC[ix1,3]            ,nil})
	aAdd(aParcelas,{"E1_VENCREA" , DataValida(aColsC[ix1,3]),nil})
	aAdd(aParcelas,{"E1_VALOR"   , aColsC[ix1,4]            ,nil})
	aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord2                ,nil})
	aAdd(aParcelas,{"E1_DATABOR" , dDatBord2                ,nil})
	aAdd(aParcelas,{"E1_PORTADO" , cCodBco2                 ,nil})
	aAdd(aParcelas,{"E1_PREFORI" , cPrefix                  ,nil})
	aAdd(aParcelas,{"E1_SITUACA" , cTipCob                  ,nil})
	aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              ,nil})
	pergunte("FIN040",.F.)  
	_nRecSA1 := SA1->(Recno()) //salva posicao
	
	MSExecAuto({|x| FINA040(x)},aParcelas)
	
	SA1->(Dbgoto(_nRecSA1))	 //retorna posicao

	
	if lMsErroAuto
		Help(" ",1,"ERROGERACR") // Erro na Geracao do Contas a Receber
		DisarmTransaction()
		Break
	Endif
	
	if Alltrim(GetMV("MV_BXVEI")) == "S"
		if DTOS(aColsC[ix1,3]) == DTOS(dDataBase)   // Se for a Vista <Baixa>
			aTitulos  := {}
			
			AADD(aTitulos,{"E1_PREFIXO"  ,cPrefNF           ,Nil})
			AADD(aTitulos,{"E1_NUM"      ,cNumTit           ,Nil})
			AADD(aTitulos,{"E1_PARCELA"  ,cParcela          ,Nil})
			AADD(aTitulos,{"E1_TIPO"     ,aColsC[ix1,1]     ,Nil})
			AADD(aTitulos,{"AUTOTBX"     ,"NOR"             ,Nil})
			AADD(aTitulos,{"AUTDTBAIXA"  ,dDataBase         ,Nil})
			AADD(aTitulos,{"AUTDTCREDITO",dDataBase         ,Nil})
			AADD(aTitulos,{"AUTHIST"     ,STR0369			,Nil}) //Baixa Automatica
			AADD(aTitulos,{"AUTVALREC"   ,aColsC[ix1,4]     ,Nil})
			
			MSExecAuto({|x| FINA070(x)},aTitulos)
			
			if lMsErroAuto
				Help(" ",1,"ERROBXATAV") // Erro na Baixa do Titulo a Vista
				DisarmTransaction()
				Break
			Endif
		Endif
	Endif
Next

// Financiamento - Integracao com Microsiga
nCont:=0
For ix1 :=1 to Len(aIteParc)
	if Empty(aIteParc[ix1,1]) .or. aIteParc[ix1,2] == 0
		Loop
	Endif
	
	nCont++
	if TamSx3("E1_PARCELA")[1] == 1
		cParcela := ConvPN2PC(ncont)
	Else
		//								cParcela := Soma1( ALLTRIM(str(ncont-1)) )
		cParcela := Soma1( strZERO(ncont-1,TamSx3("E1_PARCELA")[1]) )
	Endif
	
	aFinanc := {}
	aAdd(aFinanc,{"E1_PREFIXO" , cPrefNF                    ,nil})
	aAdd(aFinanc,{"E1_NUM"     , cNumTit                    ,nil})
	aAdd(aFinanc,{"E1_PARCELA" , cParcela                   ,nil})
	aAdd(aFinanc,{"E1_TIPO"    , "DP "                      ,nil})
	aAdd(aFinanc,{"E1_NATUREZA", SA1->A1_NATUREZ            ,nil})
	aAdd(aFinanc,{"E1_CLIENTE" , SA1->A1_COD                ,nil})
	aAdd(aFinanc,{"E1_LOJA"    , SA1->A1_LOJA               ,nil})
	aAdd(aFinanc,{"E1_EMISSAO" , dDataBase                  ,nil})
	aAdd(aFinanc,{"E1_VENCTO"  , aIteParc[ix1,1]            ,nil})
	aAdd(aFinanc,{"E1_VENCREA" , DataValida(aIteParc[ix1,1]),nil})
	aAdd(aFinanc,{"E1_VALOR"   , aIteParc[ix1,2]            ,nil})
	aAdd(aFinanc,{"E1_NUMBOR"  , cNumBord                   ,nil})
	aAdd(aFinanc,{"E1_DATABOR" , dDatBord                   ,nil})
	aAdd(aFinanc,{"E1_PORTADO" , cCodBco                    ,nil})
	aAdd(aFinanc,{"E1_PREFORI" , cPrefix                    ,nil})
	aAdd(aFinanc,{"E1_SITUACA" , cTipCob                    ,nil})
	aAdd(aFinanc,{"E1_ORIGEM" , "MATA460"              ,nil})
	pergunte("FIN040",.F.)	
	_nRecSA1 := SA1->(Recno())//Salva posicao SA1
		
	MSExecAuto({|x| FINA040(x)},aFinanc)
			
	SA1->(Dbgoto(_nRecSA1))//Volta posicao SA1
	
	if lMsErroAuto
		Help(" ",1,"ERROGERACR") // Erro na Geracao do Contas a Receber
		DisarmTransaction()
		Break
	Endif
	
	if Alltrim(GetMV("MV_BXVEI")) == "S"
		if DTOS(aIteParc[ix1,1]) == DTOS(dDataBase)   // Se for a Vista Baixa
			aBaixa  := {{"E1_PREFIXO"  ,cPrefNF ,Nil},;
			{"E1_NUM"	   ,cNumTit              ,Nil},;
			{"E1_PARCELA"  ,cParcela             ,Nil},;
			{"E1_TIPO"	   ,"DP "                ,Nil},;
			{"AUTMOTBX"	   ,"NOR"                ,Nil},;
			{"AUTDTBAIXA"  ,dDataBase            ,Nil},;
			{"AUTDTCREDITO",dDataBase            ,Nil},;
			{"AUTHIST"	   ,STR0369   			,Nil},; //baixa automatica
			{"AUTVALREC"   ,aIteParc[ix1,2]     ,Nil }}
			
			MSExecAuto({|x| FINA070(x)},aBaixa)
			If lMsErroAuto
				Help(" ",1,"ERROBXATAV") // Erro na Baixa do Titulo a Vista
				DisarmTransaction()
				Break
			EndIf
		Endif
	Endif
Next

if lTroca .and. GetNewPar("MV_GE2TRTR","S") == "S" //Troca com Troco
	nValPar := 0
	For i_:=1 to Len(aColsC)
		nValPar += aColsC[i_,FG_POSVAR("VS9_VALPAG","aHeaderC")]
	Next
	if nValPar > nTotEnt
		
		nRecSA1 := 0
		If VV0->VV0_TIPVEN == "CA" .and. !Empty(VV0->VV0_CLIALI)
			nRecSA1 := SA1->(recno())
			DbSelectArea("SA1")
			DbSeek(xFilial("SA1")+VV0->VV0_CLIALI+VV0->VV0_LOJALI)
		Endif
		dbSelectArea("SA2")
		dbSetOrder(3)
		If  !dbSeek(xFilial("SA2")+SA1->A1_CGC)
			// Cria Fornecedor
			aCabFornecedor := {}
			aAdd(aCabFornecedor,{"A2_COD"     ,GetSxENum("SA2","A2_COD") ,Nil})
			aAdd(aCabFornecedor,{"A2_LOJA"    ,SA1->A1_LOJA      ,Nil})
			aAdd(aCabFornecedor,{"A2_NOME"    ,SA1->A1_NOME      ,Nil})
			aAdd(aCabFornecedor,{"A2_TIPO"    ,SA1->A1_TIPO      ,Nil})
			aAdd(aCabFornecedor,{"A2_CGC"     ,SA1->A1_CGC       ,Nil})
			aAdd(aCabFornecedor,{"A2_NREDUZ"  ,SA1->A1_NREDUZ    ,Nil})
			aAdd(aCabFornecedor,{"A2_END"     ,SA1->A1_END       ,Nil})
			aAdd(aCabFornecedor,{"A2_BAIRRO"  ,SA1->A1_BAIRRO    ,Nil})
			aAdd(aCabFornecedor,{"A2_MUN"     ,SA1->A1_MUN       ,Nil})
			aAdd(aCabFornecedor,{"A2_EST"     ,SA1->A1_EST       ,Nil})
			aAdd(aCabFornecedor,{"A2_CEP"     ,SA1->A1_CEP       ,Nil})
			aAdd(aCabFornecedor,{"A2_DDD"     ,SA1->A1_DDD       ,Nil})
			aAdd(aCabFornecedor,{"A2_TEL"     ,SA1->A1_TEL       ,Nil})
			aAdd(aCabFornecedor,{"A2_FAX"     ,SA1->A1_FAX       ,Nil})
			aAdd(aCabFornecedor,{"A2_EMAIL"   ,SA1->A1_EMAIL     ,Nil})
			aAdd(aCabFornecedor,{"A2_ATIVIDA" ,SA1->A1_ATIVIDA   ,Nil})
			aAdd(aCabFornecedor,{"A2_SATIV1"  ,SA1->A1_SATIV1    ,Nil})
			aAdd(aCabFornecedor,{"A2_TIPO"    ,SA1->A1_PESSOA    ,Nil})
			
			ConfirmSx8()
			
			MsErroAuto := .f.
			MSExecAuto({|x,y| MATA020(x)},aCabFornecedor)
			If lMsErroAuto
				DisarmTransaction()
				Break
			EndIf
		Endif
		
		cCodBco2 := M->VV0_CODBCO
		cNumBord2:= ""
		dDatBord2:= cTod("")
		FG_Seek("SA6","cCodBco2",1,.f.)
		if SA6->A6_BORD == "0"
			cNumBord2 := "BCO"+SA6->A6_COD
			dDatBord2 := dDataBase
		Endif
		
		cCodCli   := SA2->A2_COD//M->VV0_CODCLI
		cLojCli   := SA2->A2_LOJA//M->VV0_LOJA
		cNatureza := SA2->A2_NATUREZ
		nValParc  := nValPar - nTotEnt
		aVetDesp  := {}
		aAdd(aVetDesp,{"E2_PREFIXO"  ,cSerie      ,Nil})
		aAdd(aVetDesp,{"E2_NUM"      ,cNota       ,Nil})
		aAdd(aVetDesp,{"E2_TIPO"     ,"DP "       ,Nil})
		aAdd(aVetDesp,{"E2_NATUREZ"  ,cNatureza   ,Nil})
		aAdd(aVetDesp,{"E2_PARCELA"  ,"1"         ,Nil})
		aAdd(aVetDesp,{"E2_FORNECE"  ,SA2->A2_COD ,Nil})
		aAdd(aVetDesp,{"E2_LOJA"     ,SA2->A2_LOJA,Nil})
		aAdd(aVetDesp,{"E2_NOMFOR "  ,SA2->A2_NREDUZ,Nil})
		aAdd(aVetDesp,{"E2_EMISSAO"  ,dDataBase   ,Nil})
		aAdd(aVetDesp,{"E2_VENCTO"   ,dDataBase   ,Nil})
		aAdd(aVetDesp,{"E2_VALOR"    ,nValParc    ,Nil})
		aAdd(aVetDesp,{"E2_VLCRUZ"   ,nValParc    ,Nil})
		aAdd(aVetDesp,{"E2_NUMBOR"   ,cNumBord2   ,Nil})
		aAdd(aVetDesp,{"E2_PORTADO"  ,cCodBco2    ,Nil})
		aAdd(aVetDesp,{"E2_PREFORI"  ,cPrefix     ,nil})
		pergunte("FIN050",.F.)
		lMsHelpAuto := .t.
		lMsErroAuto := .f.
		MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		If nRecSA1 > 0
			SA1->(DbGoto(nRecSA1))
		Endif
	Endif
Endif

//Ponto de entrada depois da gravacao dos titulos
If ExistBlock("VM010TIT")
	ExecBlock("VM010TIT",.f.,.f.)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_LIBVEI      ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtro da COnsulta COR no SXB                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LIBVEI()

Local lLiberado := .t.
Local lGravaNL  := .t.

if !Empty(cNumLib)
	FS_CHKLIB()
	Return(.t.)
Endif

if MsgYesNo(OemToAnsi(STR0239),OemToAnsi(STR0199))
	
	dbSelectArea("VS6")
	RecLock("VS6",.t.)
	
	PRIVATE aMemos  := {{"VS6_OBSMEM","VS6_OBSERV"}}
	
	cObserv := MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1])
	
	DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0240) FROM  02,04 TO 14,56 OF oMainWnd
	
	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1
	
	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()
	
	ACTIVATE MSDIALOG oDlg1 CENTER
	
	Begin Transaction
	
	VS6->VS6_FILIAL := xFilial("VS6")
	VS6->VS6_NUMIDE := GetSxENum("VS6","VS6_NUMIDE")
	VS6->VS6_TIPAUT := "3"
	VS6->VS6_CODCLI := M->VV0_CODCLI
	VS6->VS6_LOJA   := M->VV0_LOJA
	VS6->VS6_DATOCO := dDataBase
	VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
	VS6->VS6_NUMORC := Right(M->VV0_NUMTRA,8)
	VS6->VS6_TIPOCO := "000008"
	VS6->VS6_DESOCO := "DESCONTOS"
	VS6->VS6_USUARI := substr(cUsuario,7,15)
	VS6->VS6_FORPAG := cTipPag
	MSMM(,TamSx3("VS6_OBSERV")[1],,cObserv,1,,,"VS6","VS6_OBSMEM")
	ConfirmSx8()
	MsUnlock()
	
	aMemos  := {{"VS6_OBSMEM","VS6_OBSERV"}}
	cNumLib := VS6->VS6_NUMIDE
	M->VV0_NUMLIB := cNumLib
	M->VV0_OPEMOV := "0"
	
	dbSelectArea("VV0")
	RecLock("VV0",.f.)
	VV0->VV0_NUMLIB := M->VV0_NUMLIB
	MsUnlock()
	
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	
	dbSelectArea("VS7")
	RecLock("VS7",.t.)
	VS7->VS7_FILIAL := xFilial("VS7")
	VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
	VS7->VS7_SEQUEN := "0001"
	VS7->VS7_TIPAUT := "3" // Veiculos
	VS7->VS7_GRUITE := SB1->B1_GRUPO
	VS7->VS7_CODITE := M->VVA_CHASSI
	VS7->VS7_VALORI := M->VVA_VALMOV
	VS7->VS7_VALPER := M->VVA_VCAVEI + M->VVA_VALDES + M->VVA_ICMVEN + M->VVA_PISVEN + M->VVA_COFVEN
	VS7->VS7_VALDES := M->VVA_VCAVEI + M->VVA_VALDES + M->VVA_ICMVEN + M->VVA_PISVEN + M->VVA_COFVEN
	MsUnlock()
	
	dbSelectArea("VV0")
	
	End Transaction
	
	nValLib := M->VVA_VALMOV
	
Endif

Return .f.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRVACE     ³ Autor ³  Andre           ³ Data   08/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava Acessorios do modelo                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVACE(cPar)

Local lAcha
Local i := 0

if cPar == "VV6"
	
	dbSelectArea("VVT")
	dbSetorder(2)
	dbSeek(xFilial("VVT"))
	if dbSeek(xfilial("VVT")+M->VV0_NUMTRA)
		while !eof() .and. VVT_NUMTRA == M->VV0_NUMTRA .and. VVT->VVT_FILIAL == xFilial("VVT")
			dbSelectArea("VV6")
			dbSetorder(1)
			lAcha := dbSeek(xFilial("VV6")+M->VV1_CHAINT+VVT->VVT_GRUITE+VVT->VVT_CODITE)
			if !RecLock("VV6",If(lAcha,.F.,.T.))
				Help("  ",1,"REGNLOCK")
				DisarmTransaction()
				Break
			Endif
			VV6->VV6_FILIAL := xFilial("VV6")
			VV6->VV6_TIPREG := VVT->VVT_TIPREG
			VV6->VV6_CODOPC := VVT->VVT_CODOPC
			VV6->VV6_CHAINT := VVT->VVT_CHAINT
			VV6->VV6_FORMUL := VVT->VVT_FORMUL
			VV6->VV6_GRUITE := VVT->VVT_GRUITE
			VV6->VV6_CODITE := VVT->VVT_CODITE
			VV6->VV6_VALEQP := VVT->VVT_VALEQP
			VV6->VV6_DATINS := VVT->VVT_DATINS
			VV6->VV6_ATIVSN := VVT->VVT_ATIVSN
			MsUnlock()
			dbSelectArea("VVT")
			dbSkip()
		Enddo
	Endif
	
Else
	
	If !lCarDad
		FS_CARDAD(nOpc)
	Endif
	
	nValEqp := 0
	
	If left(aHeader[2,2],3) # "VVT"
		aHeader := aClone(aHeaderEq)
		aCols   := aClone(aColsEq)
	Endif
	
	For i = 1 to len(aCols)
		
		dbSelectArea("VVT")
		dbSetorder(2)
		lAcha := dbSeek(xFilial("VV6")+M->VV0_NUMTRA+aCols[i,FG_POSVAR("VVT_GRUITE")]+aCols[i,FG_POSVAR("VVT_CODITE")])
		
		If Inclui .or. Altera
			
			If aCols[i,len(aCols[i])] .And. Altera .And. lACha
				RecLock("VVT",.F.,.T.)
				Dbdelete()
				MsUnlock()
				WriteSx2("VVT")
			Else
				If !aCols[i,len(aCols[i])]
					RecLock("VVT",If(lAcha,.F.,.T.))
					FG_GRAVAR("VVT",aCols,aHeader,i)
					VVT->VVT_FILIAL := xFilial("VVT")
					VVT->VVT_CHAINT := VV1->VV1_CHAINT
					VVT->VVT_NUMTRA := M->VV0_NUMTRA
					VVT->VVT_ATIVSN := "1"
					MsUnlock()
				Endif
			Endif
			
		Endif
		
	Next
	
	nValEqp := 0
	
	dbSelectArea("VVT")
	dbSetorder(2)
	dbSeek(xfilial("VVT")+M->VV0_NUMTRA)
	While VVT->VVT_NUMTRA+VVT->VVT_CHAINT == M->VV0_NUMTRA+M->VVA_CHAINT .and. !Eof() .and. VVT->VVT_FILIAL == xFilial("VVT")
		If VVT_ATIVSN == "1" // Ativo
			nValEqp := nValEqp + VVT_VALEQP
		Endif
		dbSkip()
	Enddo
	
	VVF->(dbSetOrder(1))
	VVF->(dbSeek(xFilial("VVF")+VV1->VV1_TRACPA))
	VVG->(dbSetOrder(1))
	VVG->(dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+VV1->VV1_CHAINT))
	//	nCusAce := if(M->VVA_VCAVEI==0,FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase) + nValEqp, M->VVA_VCAVEI + nValEqp)
	If M->VVA_VCAVEI==0
		nCusAce := VVG->VVG_VCNVEI + nValEqp
	Else
		nCusAce := M->VVA_VCAVEI + nValEqp
	Endif
	M->VVA_ACESSO := nValEqp
	
	if nValEqp # 0
		if !lPriVez .and. Inclui
			if cEstoque == "S"
				//   			FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
				FS_FisRef("IT_VALMERC",M->VVA_VALVDA)
				FS_FisRef("IT_DESPESA",M->VV0_DESACE)
				FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
				M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
				if  cTipFat == "2"
					M->VVA_VBAICM := 0
					M->VVA_ICMVEN := 0
				Else
					M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
					M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
				Endif
			Else
				//				M->VVA_VALMOV := M->VVA_VALVDA+nValEqp
				M->VVA_VALMOV := M->VVA_VALVDA
			Endif
			
		Elseif !Inclui
			if cEstoque == "S"
				//				FS_FisRef("IT_VALMERC",M->VVA_VALVDA+nValEqp)
				FS_FisRef("IT_VALMERC",M->VVA_VALVDA)
				FS_FisRef("IT_DESPESA",M->VV0_DESACE)
				FS_FisRef("IT_DESCONTO",M->VVA_VALDES)
				M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
				
				if  cTipFat == "2"
					M->VVA_VBAICM := 0
					M->VVA_ICMVEN := 0
				Else
					M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
					M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
				Endif
			Else
				//				M->VVA_VALMOV := M->VVA_VALVDA+nValEqp
				M->VVA_VALMOV := M->VVA_VALVDA
			Endif
		Endif
	Endif
	if  cTipFat == "2"
		nTotEnt := M->VVA_VALCVD
	Else
		nTotEnt := M->VVA_VALMOV
	Endif
	lPriVez := .f.
	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CONDFAT     ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicializa na Alteracao, os Arrays de Formas de Pagamento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function FS_CONDFAT()

if Type("lTroca") <> "U" .and. lTroca
Return .t.
Endif

SE4->(dbSetOrder(1))
if SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
if Val(AllTrim(SE4->E4_COND)) > 0 .and. M->VV0_TIPFAT # "2"
FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,"VV0_FORPAG",nTotEnt)
Else
FG_DesfPag()
cCondic1:=ctod(" ")
cCondic2:=space(02)
cCondic3:=space(02)
cCondic4:=space(02)
Endif
Endif

Return
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FDSCANIA    ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela p/ Informacao de dados referentes ao Fat. Direto da    ³±±
±±³          ³SCANIA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FDSCANIA()

wRet := .f.

nOpcaFD := 0
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0032) FROM  02,04 TO 11,76 OF oMainWnd // Tipo de Faturamento

@ 07,004 SAY OemToAnsi(STR0174) OF oDlg PIXEL COLOR CLR_BLUE
@ 07,044 MSGET oPerICM VAR M->VVA_ALIICM PICTURE "@E 99.99" SIZE 38,4 OF oDlg PIXEL COLOR CLR_BLACK
@ 07,094 SAY OemToAnsi(STR0175) OF oDlg PIXEL COLOR CLR_BLUE
@ 07,134 MSGET oPerIPI VAR M->VVA_ALIIPI PICTURE "@E 99.99" SIZE 38,4 OF oDlg PIXEL COLOR CLR_BLACK
@ 07,184 SAY OemToAnsi(STR0176) OF oDlg PIXEL COLOR CLR_BLUE
@ 07,224 MSGET oPerPICO VAR M->VVA_ALIPIC PICTURE "@E 99.99" SIZE 38,4 OF oDlg PIXEL COLOR CLR_BLACK
@ 20,094 SAY OemToAnsi(STR0177) OF oDlg PIXEL COLOR CLR_BLUE
@ 20,134 MSGET oValReal VAR M->VVA_VRENET PICTURE "@E 999,999,999.99" OF oDlg PIXEL COLOR CLR_BLACK

DEFINE SBUTTON FROM 47,24 TYPE 1 ACTION (nOpcaFD := 1,oDlg:End());
ENABLE OF oDlg
DEFINE SBUTTON FROM 47,55 TYPE 2 ACTION (nOpcaFD := 2,oDlg:End());
ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

if nOpcaFD == 1
	wret := .t.
Endif
oPerDes:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_APAGSIMUL   ³ Autor ³  Andre           ³ Data   19/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Limpa Simulacoes existentes do Veiculo que acaba de ser     ³±±
±±³          ³Faturado                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_APAGSIMUL()
Local lAchou := .t.

dbSelectArea("VVA")
if !Empty(VVA->VVA_CHASSI)
	dbSetOrder(2)
	lAchou := dbSeek(xFilial("VVA")+M->VVA_CHASSI)
Else
	dbSetOrder(1)
	lAchou := dbSeek(xFilial("VVA")+M->VVA_NUMTRA)
Endif

While (!eof()) .and. (lAchou) .and. iif(!Empty(VVA->VVA_CHASSI),VVA->VVA_CHASSI == M->VVA_CHASSI .and. VVA->VVA_FILIAL == xFilial("VVA"),.t.)
	VV0->(dbSetOrder(1))
	VV0->(dbSeek(xFilial("VV0")+VVA->VVA_NUMTRA))
	if VV0->VV0_OPEMOV $ "15"
		dbSelectArea("VV0")
		RecLock("VV0",.f.,.t.)
		DbDelete()
		MsUnlock()
		WriteSx2("VV0")
		
		dbSelectArea("VVA")
		RecLock("VVA",.f.,.t.)
		DbDelete()
		MsUnlock()
		WriteSx2("VVA")
	Endif
	dbSkip()
Enddo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AL_INICIA      ³ Autor ³  Manoel          ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Salva variaveis ambientais                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AL_Inicia()
aTela := aClone(aSvATela[1])
aGets := aClone(aSvAGets[1])
dbSelectArea("VV1")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AL_ENTRA       ³ Autor ³  Manoel          ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Salva variaveis ambientais                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AL_Entra(nE,cAlias)
aTela := AClone(aSvAtela[nE])
aGets := AClone(aSvaGets[nE])
dbSelectArea(cAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AL_SAI         ³ Autor ³  Manoel          ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Salva variaveis ambientais                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Al_Sai(nE)
aSvATela[nE]	:= aClone(aTela)
aSvAGets[nE]   	:= aClone(aGets)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FINVM010    ³ Autor ³  Manoel          ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz chamada das funcoes de gravacao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FINVM010(nOpc,lLib)

Local cTip
Local lRet       := .t.
Local lSerie     := .f.
Local cMVCrmVei  := GetMv("MV_CRMVEI",,"NNNN")
Local aColsSlv   := aclone(aCols)
Local aHeaderSlv := aclone(aHeader)

Private cMsg   := ""
Private nValPar:= 0
Private lEmitiu:= .f.

// CRM
Private cCrmVei := ""

Default lLib := .f.

if nOpc == 2
	Return (.t.)
Endif

if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "S"	//Integrado com o Sigaloja ?
	if !inclui .and. !Empty(VV0->VV0_PESQLJ)
		MsgInfo(STR0370 ,STR0015)  //Orcamento do Loja ja foi Gerado... - Atencao!
		Return .f.
	Endif
Endif

lMsHelpAuto := .f.
lMsErroAuto := .f.

cTexto := STR0241
Do Case
	Case cParPrg == "2"
		if M->VV0_AUTFAT = "0"
			cTexto := STR0242
		Else
			cTexto := STR0243
		Endif
	Case cParPrg == "3"; cTexto := STR0243
EndCase
if !lLib
	if !MsgYesNo(cTexto,STR0199)
		Return(.f.)
	Endif
Endif

If !lLib .and. cParPrg == "2" .and. M->VV0_AUTFAT <> "0" .and. Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "N"
	lSerie := Sx5NumNota(.T.,GetNewPar("MV_TPNRNFS","1"))
	If lSerie == .F.
		MsgStop(STR0244)
		Return .f.
	Endif
Endif

if cParPrg == "2"
	// Ponto de Entrada Antes da Gravacao do Pedido
	If ExistBlock("VM010APD") .and. Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "N"
		ExecBlock("VM010APD",.f.,.f.)
	EndIf
Endif

if (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") .and. Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "N"
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VM010ANF")
		ExecBlock("VM010ANF",.f.,.f.)
	EndIf
Endif

//CRM
If Subs(cMVCrmVei,1,1) == "S" .and. Subs(cMVCrmVei,3,1) == "S"
	If cParPrg =="2"
		If FG_PESQTAB("VV0_CRMOK1") .and. Pergunte("CRMVEI",.T.)
			cCrmVei	:= MV_PAR01
		Endif
	Elseif (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
		If FG_PESQTAB("VV0_CRMOK2") .and. Pergunte("CRMVEI",.T.)
			cCrmVei	:= MV_PAR01
		Endif
	Endif
EndIf

//if !FG_SEMAFORO("SX5")
//   Return(.f.)
//Endif

//Por mais estranho que pareca esta funcao deve ser chamada aqui, antes da transacao - nao mexer - farinelli
If Select("__SE1")==0
	SumAbatRec( "", "", "", 1, "")
Endif

Begin Transaction
if nOpca == 1 .and. (nopc == 3 .or. nopc == 4)
	if cParPrg == "1" // Simulacao
		ProcRegua(2)
		M->VV0_OPEMOV := "1"
		lRet := FS_GRAVA010("S",nOpc)
		cTip := "S"
	Elseif (cParPrg == "2" .and. M->VV0_AUTFAT == "0") // Proposta ou Pedido
		ProcRegua(4)
		M->VV0_OPEMOV := "0"
		lReserv := .t.
		lRet := FS_GRAVA010("S",nOpc)
		lRet := FS_GRAVA010("G",nOpc,lLib)
		cTip := "G"
	Elseif (cParPrg == "2" .and. M->VV0_AUTFAT <> "0") // Faturamento
		if VV0->VV0_TIPFAT == "2"
			if MsgYesNo(STR0408,OemToAnsi(STR0015)) //Deseja Faturar o Veiculo?
				M->VV0_AUTFAT := "1"				
				if MsgYesNo(OemToAnsi(STR0245),OemToAnsi(STR0015))
					M->VVA_EMINVD := "1"
				Else
					M->VVA_EMINVD := "0"
				Endif
			Endif
		Else
			M->VVA_EMINVD := "0"
		Endif
		
		ProcRegua(4)
		M->VV0_OPEMOV := "0"
		lRet := FS_GRAVA010("S",nOpc)
		lRet := FS_GRAVA010("G",nOpc,lLib)
		FS_GRVACE("VV6")
		cTip := " "
		
	Endif
	if lDeleta .and. Inclui
		
		dbSelectArea("VV0")
		RecLock("VV0",.f.,.t.)
		DbDelete()
		MsUnlock()
		WriteSx2("VV0")
		
		dbSelectArea("VVA")
		RecLock("VVA",.f.,.t.)
		DbDelete()
		MsUnlock()
		WriteSx2("VVA")
		
	Endif
Else
	if lJaGrv .and. cTipFat # "2" .and. (nopc == 3 .or. nopc == 4) .and. Inclui
		lRet := FS_GRAVA010("D",nOpc)
		cTip := "D"
	Endif
Endif
End Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

SX5->(MsRUnLock())

if cTipSai == "0" .and. cTipFat <> "2" .and. (cParPrg == "2" .and. M->VV0_AUTFAT <> "0")
	if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "S"	//Integrado com o Sigaloja ?
		MsgInfo(STR0371 +" " + VV0->VV0_PESQLJ,STR0372)   //Orcamento Nro: + Operacao OK
		Return .t.
	Endif
Endif

//FG_SEMAFORO("SX5","L")

if cParPrg == "2"
	// Ponto de Entrada Depois da Gravacao do Pedido
	If ExistBlock("VM010DPD")
		ExecBlock("VM010DPD",.f.,.f.)
	EndIf
Endif

if cParPrg == "3"
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If ExistBlock("VM010DNF")
		ExecBlock("VM010DNF",.f.,.f.)
	EndIf
	///////////////////////////////////////
	// Manoel - 07/04/2009  -   Quando criar novo Atendimento - colocar estes criterios na gravacao
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	If dbseek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		dbSelectArea("VV0")
		If dbseek(xfilial("VV0")+SD2->D2_DOC+SD2->D2_SERIE)
		
			if SD2->D2_GRUPO == cGruVei .and. VV0->VV0_OPEMOV == "0"
				
				dbSelectArea("VV0")
				if dbseek(xfilial("VV0")+SD2->D2_DOC+SD2->D2_SERIE)
				
					dbSelectArea("VVA")
					if dbseek(xfilial("VVA")+VV0->VV0_NUMTRA)
						
						dbSelectArea("VV1")
						dbseek(xfilial("VV1")+VVA->VVA_CHAINT)
						
						dbSelectArea("VVG")
						if dbseek(xfilial("VVG")+VVA->VVA_TRACPA+VVA->VVA_CHAINT)
							
							dbSelectArea("VVF")
							dbgotop()
							if dbseek(xfilial("VVF")+VVG->VVG_TRACPA)
								
								dbSelectArea("VVH")
								dbgotop()
								if dbseek(xfilial("VVH")+VVG->VVG_CODIND)
									
									w_cusvda := FG_CusVei(VVA->VVA_TRACPA,VVG->VVG_CHAINT,VVF->VVF_DATEMI,VV0->VV0_DATMOV)
									
									dbselectarea("SD2")
									reclock("SD2",.f.)
									SD2->D2_CUSTO1 := VVG->VVG_VCNVEI+VVG->VVG_VALFRE
									msunlock()
									
									dbselectarea("VVA")
									reclock("VVA",.f.)
									
									VVA->VVA_VALMOV := SD2->D2_TOTAL
									VVA->VVA_FATTOT := VVA->VVA_VALMOV+VVA->VVA_COMCOT+VVA->VVA_COMCTP+VVA->VVA_RECTEC+VVA->VVA_BONFAB
									VVA->VVA_VALVDA := SD2->D2_TOTAL
									VVA->VVA_VCAVEI := VVG->VVG_VCNVEI
									VVA->VVA_VBAICM := SD2->D2_BASEICM
									VVA->VVA_ICMVEN := SD2->D2_VALICM 
									                   
									If w_cusvda > VVG->VVG_VCNVEI
										 VVA->VVA_JUREST := w_cusvda - VVG->VVG_VCNVEI
									Endif						
									
									//						VVA->VVA_TOTDES := 0
									//						VVA->VVA_TMFDES := 0
									//						VVA->VVA_VALREV := 0
									//						VVA->VVA_VMFREV := 0
									
									if VVA->VVA_ESTVEI = "0"  //NOVO
										
										VVA->VVA_COFVEN := 0
										VVA->VVA_PISVEN := 0
										
									else
										
										if (VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)) > 0
											VVA->VVA_COFVEN := (VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE))*0.03
											VVA->VVA_PISVEN := (VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE))*0.0065
										else
											VVA->VVA_COFVEN := 0
											VVA->VVA_PISVEN := 0
										endif
										
									endif
									
									VVA->VVA_VALFRE := VVG->VVG_VALFRE
									
									VVA->VVA_TOTCUS := VVA->VVA_VCAVEI-VVA->VVA_REDCUS+VVA->VVA_JUREST+VVA->VVA_VALFRE+VVA->VVA_ACESSO+VVA->VVA_VDESCO //+VVA->VVA_PISENT+VVA->VVA_COFENT
									
									VVA->VVA_TOTDES := VVA->VVA_DESVEI+VVA->VVA_DESCLI+VVA->VVA_SEGVIA+VVA->VVA_VALASS+VVA->VVA_VALREV+VVA->VVA_ASSIMP+VVA->VVA_DESFIX
									VVA->VVA_TOTIMP := VVA->VVA_ICMVEN+VVA->VVA_ISSCVD+VVA->VVA_PISVEN+VVA->VVA_COFVEN+VVA->VVA_ISSRTE+VVA->VVA_PISRTE+VVA->VVA_ISSBFB+VVA->VVA_PISBFB
		
									VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_TOTIMP-VVA->VVA_VCAVEI-VVA->VVA_VALFRE  //LUCRO BRUTO
									
									VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
									VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)      //LAIR
									
									msunlock()
									
								endif
								
							endif
							
						endif
						
					endif
					
				endif
				
				dbSelectArea("SD2")
				
				if VVA->VVA_ESTVEI = "1"  //USADO
					IF (VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)) > 0
						reclock("SD2",.f.)
						SD2->D2_BASIMP5 := (VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE))
						SD2->D2_BASIMP6 := (VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE))
						SD2->D2_VALIMP5 := VVA->VVA_COFVEN
						SD2->D2_VALIMP6 := VVA->VVA_PISVEN
						If SD2->D2_VALIMP5 == 0
							SD2->D2_ALQIMP5 := 0
						Endif
						If SD2->D2_VALIMP6 == 0
							SD2->D2_ALQIMP6 := 0
						Endif
			
						if !type("SD2->D2_V10") == "U"
							SD2->D2_V10 := space(1)
						endif
						msunlock()
					else
						reclock("SD2",.f.)
						SD2->D2_BASIMP5 := 0
						SD2->D2_BASIMP6 := 0
						SD2->D2_VALIMP5 := 0
						SD2->D2_VALIMP6 := 0
						SD2->D2_ALQIMP5 := 0
						SD2->D2_ALQIMP6 := 0
						if !type("SD2->D2_V10") == "U"
							SD2->D2_V10 := space(1)
						endif
						msunlock()
					endif
				endif
			
			  DbSelectArea("SFT")
			  DbSetOrder(6)
			  DbSeek(xFilial("SFT") + "S" + SD2->D2_DOC + SD2->D2_SERIE)
			  If (SFT->FT_NFISCAL == SD2->D2_DOC .and. SFT->FT_CLIEFOR + SFT->FT_LOJA == SD2->D2_CLIENTE + SD2->D2_LOJA)
			  	RecLock("SFT",.f.)
			  	SFT->FT_VALCOF 	:= SD2->D2_VALIMP5
			  	SFT->FT_VALPIS 	:= SD2->D2_VALIMP6
			  	SFT->FT_BASECOF	:= SD2->D2_BASIMP5
			  	SFT->FT_BASEPIS	:= SD2->D2_BASIMP6
			  	SFT->FT_ALIQCOF	:= SD2->D2_ALQIMP5
			  	SFT->FT_ALIQPIS	:= SD2->D2_ALQIMP6
			  	MsUnlock()
			  EndIf
			  
			  DbSelectArea("SF2")
			  DbSetOrder(1)
			  DbSeek(xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE)
			  If (SF2->F2_DOC == SD2->D2_DOC .and. SF2->F2_CLIENTE + SF2->F2_LOJA == SD2->D2_CLIENTE + SD2->D2_LOJA)
			  	RecLock("SF2",.f.)
			  	SF2->F2_VALIMP5 	:= SD2->D2_VALIMP5
			  	SF2->F2_VALIMP6 	:= SD2->D2_VALIMP6
			  	SF2->F2_BASIMP5	:= SD2->D2_BASIMP5
			  	SF2->F2_BASIMP6	:= SD2->D2_BASIMP6
			  	MsUnlock()
			  EndIf
			
			Endif

		Endif

	Endif

Endif

if cParPrg == "2" .and. VE4->VE4_GTPRFT  == "0" .and. cTipSai # "3"
	dbSelectArea("SA6")
	dbSetOrder(1)
	if dbSeek(xFilial("SA6")+M->VV0_CODBCO)
		cDesBco := ""
		cObs1   := Substr(SA6->A6_MENSAGE,001,49)
		cObs2   := Substr(SA6->A6_MENSAGE,050,49)
		cObs3   := Substr(SA6->A6_MENSAGE,100,50)
		if ExistBlock("BLQCOB")
			ExecBlock("BLQCOB",.f.,.f.,{cNota,,,,cPrefNF,"1",cObs1,cObs2,cObs3,VV0->VV0_CODBCO})
		Endif
	Endif
Elseif cParPrg == "3" .and. cTipSai # "3"
	dbSelectArea("SA6")
	dbSetOrder(1)
	if dbSeek(xFilial("SA6")+M->VV0_CODBCO)
		cDesBco := ""
		cObs1   := Substr(SA6->A6_MENSAGE,001,49)
		cObs2   := Substr(SA6->A6_MENSAGE,050,49)
		cObs3   := Substr(SA6->A6_MENSAGE,100,50)
		if ExistBlock("BLQCOB")
			ExecBlock("BLQCOB",.f.,.f.,{cNota,,,,cPrefNF,"1",cObs1,cObs2,cObs3,VV0->VV0_CODBCO})
		Endif
	Endif
Endif

aHeader := aclone(aHeaderSlv)
aCols   := aclone(aColsSlv)

lEmitiu := .f.

if cTip == "G" .and. !lLib
	
	if  cParPrg == "3" .or.  ;// Faturamento
		(M->VV0_OPEMOV $ "2346") .and. Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "N" //Transferencia,Remessa,Devolucao e nao integrado com o LOJA
		
		IncProc(STR0246)
		if cTipPed == "N" .and. cTipFat == "2" .and. M->VVA_EMINVD == "1"   // NF de Servico Qdo Faturamento Direto
			if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
				If ExistBlock("NFSERVIC") // Programa de Nota Fiscal de Diversos
					ExecBlock("NFSERVIC",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI,"CFD"})
				Endif
			EndIF
		Elseif cTipFat # "2" // Venda/Remessa/Transferencia/Devolucao
			if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
				If ExistBlock("NFSAIVEI")
					ExecBlock("NFSAIVEI",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI})
					lEmitiu := .t.
				Endif
			EndIF
		Endif
		
	Elseif cParPrg == "2" // Proposta
		
		IncProc(STR0247)
		
		cOpcao := " "
		aOpcao := {STR0248,STR0249}
		xOpc   := 2
		
		DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0250) FROM  02,04 TO 07,35 OF oMainWnd
		
		@  13, 02 TO 33,122 LABEL OemToAnsi(STR0251) OF oDlgPerg PIXEL
		
		@  19, 04 MSCOMBOBOX oOpcao VAR cOpcao SIZE 117,50 ITEMS aOpcao OF oDlgPerg PIXEL
		
		ACTIVATE MSDIALOG oDlgPerg CENTER ON INIT (FG_ENCHOICEBAR(oDlgPerg,{|| xOpc := 1,oDlgPerg:End()},{|| xOpc := 2,oDlgPerg:End()}))
		
		if xOpc == 1
			if cOpcao == STR0248
				//Executa RdMake da Proposta de Venda
				if ExistBlock("PROPVEI")
					ExecBlock("PROPVEI",.f.,.f.,{VV0->VV0_NUMPED})
				Endif
			Else
				If !Empty(Alltrim(GETMV("MV_CRYSTAL")))
					VV2->(dbSetOrder(1))
					VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
					nDiasVld := Str(VV2->VV2_DIAVPR,2)
					CallCrys("PROPVEI",VV0->VV0_NUMPED+";"+nDiasVld)
				EndIf
			Endif
		Endif
	Endif
Endif

if !lMsErroAuto
	if cParPrg $ "2/3" .and. M->VV0_AUTFAT <> "0"
		if Type("cNota") <> "C" .or. Empty(cNota)
			cNota := VV0->VV0_NUMNFI
			cSerie:= VV0->VV0_SERNFI
		Endif
		if !lEmitiu
			if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
				If ExistBlock("NFSAIVEI")
					ExecBlock("NFSAIVEI",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI})
					lEmitiu := .t.
				Endif
			EndIf
		Endif
		
		DEFINE MSDIALOG oDlgNota TITLE OemtoAnsi(STR0252) FROM  02,04 TO 07,31 OF oMainWnd
		@ 016, 002 Say STR0253 + cNota  OF oDlgNota PIXEL FONT oFnt3
		@ 028, 002 Say STR0254 + FGX_UFSNF( cSerie ) OF oDlgNota PIXEL FONT oFnt3
		ACTIVATE MSDIALOG oDlgNota CENTER ON INIT (FG_EnchoiceBar(oDlgNota,,{|| oDlgNota:End()},1))
		
		dbSelectArea("VV0")
		cIndex := CriaTrab(nil,.f.)
		cKey   := "VV0_FILIAL+DtoS(VV0_DATMOV)"
		if cParPrg == "1"        //Simulacao
			cCond := "VV0->VV0_OPEMOV $ '15' .and. Empty(VV0->VV0_NUMPED)"
		Elseif cParPrg == "2"    //Proposta/Pedido
			cCond := "VV0->VV0_OPEMOV $ '01' .and. Empty(VV0->VV0_NUMNFI) .and. VV0->VV0_SITNFI == '1'"
		Elseif cParPrg == "3"    //Faturamento
			cCond := "VV0->VV0_OPEMOV == '0' .and. !Empty(VV0->VV0_NUMPED) .and. VV0->VV0_SITNFI == '1' .and. VV0->VV0_AUTFAT == '1'"
		Endif
		
		IndRegua("VV0",cIndex,cKey,,cCond,OemToAnsi(STR0002))  //Selecionando Registros...
		dbSelectArea("VV0")
		nIndexVV0 := RetIndex("VV0")
		#IFNDEF TOP
			dbSetIndex(cIndex+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndexVV0+1)
		
	Endif
Endif

if lMsErroAuto
	if !Empty(cMsg)
		MsgInfo(cMsg,STR0199)
		cMsg := ""
	Else
		MostraErro()
	Endif
	lRet    := .f.
	lDeleta := .t.
Endif

lMsHelpAuto := .f.

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CHKLIB      ³ Autor ³  Andre           ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa a Liberacao de Venda                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CHKLIB()

Local lRet    := .t.
Local nOpcSlv := nOpc

if !Empty(cNumLib)
	dbSelectArea("VS6")
	dbSetOrder(1)
	if dbSeek(xFilial("VS6")+cNumLib)
		if Empty(VS6->VS6_DATAUT)
			MsgInfo(OemToAnsi(STR0255),OemToAnsi(STR0199))
			lRet := .f.
		Else
			if !FG_MOSLIB(cNumLib,"2")
				lRet      := .f.
				cNumLib   := ""
				lLiberado := .f.
			Else
				MsgInfo(OemToAnsi(STR0256),OemToAnsi("Ok"))    //"Venda Liberada...","Ok"
				lRet := .t.
			Endif
		Endif
	Endif
Endif

nOpc := nOpcSlv

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_EXCLIB      ³ Autor ³  Andre           ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a Exclusao da Liberacao de Venda                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXCLIB()

if !Empty(cNumLib)
	dbSelectArea("VS6")
	dbSetOrder(1)
	if dbSeek(xFilial("VS6")+cNumLib)
		if !RecLock("VS6",.f.,.t.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		dbDelete()
		MsUnlock()
		dbSelectArea("VS7")
		dbSetOrder(1)
		dbSeek(xFilial("VS7")+cNumLib)
		if !RecLock("VS7",.f.,.t.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		dbDelete()
		MsUnlock()
	Endif
Endif

dbSelectArea("VV0")

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ALTLIB      ³ Autor ³  Andre           ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a alteracao de acordo com o novo desconto informado     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ALTLIB()

dbSelectArea("VS6")
dbSetOrder(1)
if dbSeek(xFilial("VS6")+cNumLib)
	
	if Empty(VS6->VS6_DATAUT)
		
		Help(" ",1,"VALVDANLIB")
		
		Private aMemos  := {{"VS6_OBSMEM","VS6_OBSERV"}}
		
		cObserv1 := MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1])
		
		DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0172) FROM  02,04 TO 14,56 OF oMainWnd
		
		DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
		DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1
		
		@ 01,011 GET oObserv1 VAR cObserv1 OF oDlg1 MEMO SIZE 182,67 PIXEL
		oObserv1:oFont := oFonte
		oObserv1:bRClicked := {|| AllwaysTrue()}
		oObserv1:SetFocus()
		
		ACTIVATE MSDIALOG oDlg1 CENTER
		
		dbSelectArea("VS6")
		if !RecLock("VS6",.f.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		
		VS6->VS6_FILIAL := xFilial("VS6")
		VS6->VS6_DATOCO := dDataBase
		VS6->VS6_TIPAUT := "3" // Veiculos
		VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
		VS6->VS6_TIPOCO := "000008"
		VS6->VS6_DESOCO := OemToAnsi(STR0173)
		VS6->VS6_USUARI := substr(cUsuario,7,15)
		VS6->VS6_CODCLI := M->VV0_CODCLI
		VS6->VS6_LOJA   := M->VV0_LOJA
		MSMM(,TamSx3("VS6_OBSERV")[1],,cObserv1,1,,,"VS6","VS6_OBSMEM")
		ConfirmSx8()
		MsUnlock()
		
		aMemos  := {{"VVA_OBSMEM","VVA_OBSERV"}}
		
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
		
		dbSelectArea("VS7")
		if !RecLock("VS7",.f.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		VS7->VS7_FILIAL := xFilial("VS7")
		VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
		VS7->VS7_SEQUEN := "0001"
		VS7->VS7_TIPAUT := "3" // Veiculos
		VS7->VS7_GRUITE := SB1->B1_GRUPO
		VS7->VS7_CODITE := M->VVA_CHASSI
		VS7->VS7_VALORI := M->VVA_VALMOV
		VS7->VS7_VALPER := M->VVA_VCAVEI + M->VVA_VALDES + M->VVA_ICMVEN + M->VVA_PISVEN + M->VVA_COFVEN
		VS7->VS7_VALDES := M->VVA_VCAVEI + M->VVA_VALDES + M->VVA_ICMVEN + M->VVA_PISVEN + M->VVA_COFVEN
		MsUnlock()
		
		dbSelectArea("VV0")
		
	Endif
	
Endif

Return ( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_SIMULAGRV   ³ Autor ³  Andre           ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz uma simulacao da gravacao do pedido                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SIMULAGRV()

//Variaveis do VV0
Private aVetTra := {}

M->VV0_FILIAL := xFilial("VV0")
M->VV0_DATMOV := dDatMov
M->VV0_TIPFAT := cTipFat
M->VV0_ESTCLI := cEstCli
M->VV0_NUMLIB := cNumLib
M->VV0_SITNFI := "1"  //Valida
M->VV0_DTHEMI := Dtoc(dDataBase) + [/] + Time()
M->VV0_NUMNFI := ""
M->VV0_SERNFI := ""
if FieldPos('VV0_SDOC') > 0
	M->VV0_SDOC := ""
EndIf
M->VV0_DTHEMI := Dtoc(dDataBase) + [/] + Time()
M->VV0_VALNEG := M->VVA_VALVDA

//Variaveis do VVA

M->VVA_SIMVDA := if(M->VV0_OPEMOV=="1","S","V")
M->VVA_FILIAL := xFilial("VVA")
M->VVA_NUMTRA := M->VV0_NUMTRA
if cEstoque == "S"
	M->VVA_VMFVEI := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VCAVEI} })
	M->VVA_JUREST := M->VVA_JUREST
	M->VVA_JMFEST := FG_CalcMF({ {dDataBase,M->VVA_JUREST} })
Else
	M->VVA_VMFVEI := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VCAVEI} }) + FG_CalcMF({ {M->VV0_DATMOV,nValCor} })
	M->VVA_JUREST := 0
	M->VVA_JMFEST := 0
Endif

M->VVA_ACESSO := M->VVA_ACESSO
M->VVA_AMFSSO := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_ACESSO} })

//Condicao de Pagamento
SE4->(dbSetOrder(1))
if SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG)) .and. Empty(aIteParc[1,1]) .and. !lTroca
	if val(AllTrim(SE4->E4_COND)) > 0 .and. M->VV0_TIPFAT # "2"
		FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,"VV0_FORPAG",nTotEnt)
	Else
		FG_DesfPag()
		cCondic1:=ctod(" ")
		cCondic2:=space(02)
		cCondic3:=space(02)
		cCondic4:=space(02)
	Endif
Endif

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if !VE4->VE4_GTPRFT  == "1"   // Gera titulo no Faturamento
	cPrefNF := "PRP"
Endif
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
FG_Seek("SF4","M->VVA_CODTES")

M->VVA_VMFMOV :=  FG_CalcMF(if((cParPrg=="1") .or. (cParPrg == "2" .and. VE4->VE4_GTPRFT  == "1"),FG_RetVdCp(,,"S",nTotEnt),FG_RetVdCp(M->VV0_NUMPED,cPrefNF,"S")))

If cTipFat == "2" //Faturamento Direto
	aPisCof := CalcPisCofsai(M->VVA_VALCVD)
	M->VVA_VALVDA := M->VVA_VALVDA
	M->VVA_VMFVDA := M->VVA_VMFMOV
	M->VVA_VALCVD := M->VVA_VALCVD
	nValBasCom    := M->VVA_VALCVD
	M->VVA_VMFCVD := M->VVA_VMFMOV
	M->VVA_ISSCVD := M->VVA_ISSCVD
	M->VVA_IMFCVD := FG_CalcMF( { {FG_RtDtImp("ISS",M->VV0_DATMOV),M->VVA_ISSCVD} })
	M->VVA_PISVEN := aPisCof[1,1]
	M->VVA_PMFVEN := FG_CalcMF( { {FG_RtDtImp("PIS",M->VV0_DATMOV),M->VVA_PISVEN} })
	M->VVA_COFVEN := ApISCOF[1,2]
	M->VVA_CMFVEN := FG_CalcMF( { {FG_RtDtImp("COF",M->VV0_DATMOV),M->VVA_COFVEN} })
Else
	nValBasCom     := M->VVA_VALVDA
	M->VVA_VMFVDA := M->VVA_VMFMOV - M->VVA_AMFSSO
	M->VVA_IMFVEN := FG_CalcMF( { {FG_RtDtImp("ICM",M->VV0_DATMOV),M->VVA_ICMVEN} })
	if cTipFat == "0" // Veiculo Novo
		if !(M->VVA_PISENT+M->VVA_COFENT > 0)
			If Empty(M->VVA_INPICO) .and. Left(FunName(),7) == "VEIVM01"
				if MsgYesNo(OemToAnsi(STR0257),OemToAnsi(STR0015))
					M->VVA_INPICO := "1"  //Sim
				Else
					M->VVA_INPICO := "0"  //Nao
				Endif
			Endif
			If M->VVA_INPICO == "1"
				aPisCof := CalcPisCofSai(M->VVA_VALVDA)
				M->VVA_PISVEN := aPisCof[1,1]
				M->VVA_COFVEN := aPisCof[1,2]
				M->VVA_PMFVEN := FG_CalcMF( { {FG_RtDtImp("PIS",M->VV0_DATMOV),M->VVA_PISVEN} })
				M->VVA_CMFVEN := FG_CalcMF( { {FG_RtDtImp("COF",M->VV0_DATMOV),M->VVA_COFVEN} })
			Else
				M->VVA_PISVEN := 0
				M->VVA_COFVEN := 0
				M->VVA_PMFVEN := 0
				M->VVA_CMFVEN := 0
			Endif
		else
			M->VVA_PISVEN := 0
			M->VVA_COFVEN := 0
			M->VVA_PMFVEN := 0
			M->VVA_CMFVEN := 0
		Endif
	Else
		aPisCof := CalcPisCofSai((M->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)))
		M->VVA_PISVEN := aPisCof[1,1] //(M->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)) * nAliPis
		M->VVA_COFVEN := aPisCof[1,2] //(M->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)) * nAliCof
		M->VVA_PMFVEN := FG_CalcMF( { {FG_RtDtImp("PIS",M->VV0_DATMOV),M->VVA_PISVEN }})
		M->VVA_CMFVEN := FG_CalcMF( { {FG_RtDtImp("COF",M->VV0_DATMOV),M->VVA_COFVEN }})
	Endif
Endif

if cTipSai == "0"    //Venda/Simulacao
	aAdd(aVetTra,{M->VV0_CODVEN,1})
	aValCom    := FG_COMISS("V",aVetTra,M->VV0_DATMOV,M->VV0_TIPFAT,nValBasCom,"T")
	M->VVA_COMVDE := aValCom[1]
	M->VVA_COMGER := aValCom[2]
	aValCom    := FG_COMISS("V",aVetTra,M->VV0_DATMOV,M->VV0_TIPFAT,nValBasCom,"D")
	M->VVA_CMFVDE := FG_CalcMF(  aValCom[1] )
	M->VVA_CMFGER := FG_CalcMF(  aValCom[2] )
	If M->VVA_INPCRT == "1"
		aPisCof := CalcPisCofSai(M->VVA_RECTEC)
		M->VVA_PISRTE   := aPiscof[1,1] + aPiscof[1,2]  //FG_PARSIS("COF",dDataBase,M->VVA_RECTEC) + FG_PARSIS("PIS",dDataBase,M->VVA_RECTEC) // M->VVA_PISRTE // nPiCoRt
		M->VVA_PMFRTE   := FG_CalcMF({ {FG_RtDtImp("PIS",M->VVA_DATRTC), M->VVA_PISRTE }}) //FG_PARSIS("COF",dDataBase,M->VVA_RECTEC) + FG_PARSIS("PIS",dDataBase,M->VVA_RECTEC) // M->VVA_PISRTE // nPiCoRt
	Endif
	If M->VVA_INISRT == "1"
		M->VVA_ISSRTE   := M->VVA_RECTEC * nAliIss // FG_PARSIS("ISS",dDataBase,M->VVA_RECTEC) // nIssRt
		M->VVA_IMFRTE   := FG_CalcMF({ {FG_RtDtImp("ISS",M->VVA_DATRTC),M->VVA_RECTEC * nAliIss} }) // FG_PARSIS("ISS",dDataBase,M->VVA_RECTEC) // nIssRt
	Endif
Endif

if cEstoque == "S" .or. cTipFat == "2"
	M->VVA_TRACPA := VV1->VV1_TRACPA
	M->VVA_ESTVEI := VV1->VV1_ESTVEI
	M->VVA_CODORI := VV1->VV1_CODORI
	M->VVA_ICMCOM := VVG->VVG_ICMCOM
	M->VVA_VDESCO := VVG->VVG_VDESCO
	M->VVA_VMFSCO := FG_CalcMF({ {VVF->VVF_DATMOV,M->VVA_VDESCO} })
	M->VVA_IMFCOM := FG_CalcMF( { {FG_RtDtImp("ICM",VVF->VVF_DATMOV),M->VVA_ICMCOM} })
	M->VVA_PISENT := M->VVA_PISENT
	M->VVA_PMFENT := FG_CalcMF( { {FG_RtDtImp("PIS",VVF->VVF_DATMOV),M->VVA_PISENT} })
	M->VVA_COFENT := M->VVA_COFENT
	M->VVA_CMFENT := FG_CalcMF( { {FG_RtDtImp("COF",VVF->VVF_DATMOV),M->VVA_COFENT} })
	M->VVA_EMINVD := M->VVA_EMINVD
	M->VVA_COMPGC := 0
	//Por Enquanto nao tera controle da Comissao de Cota e Contemplacao
	M->VVA_COMCOT := 0   //FG_COMISS("VC") // Comissao s/ Cota de Consorcio
	M->VVA_CMFCOT := 0   //FG_COMISS("VC") // Comissao s/ Cota de Consorcio
	M->VVA_COMCTP := 0   //FG_COMISS("VT") // Comissao s/ Contemplacao do Consorcio
	M->VVA_CMFCTP := 0   //FG_COMISS("VT") // Comissao s/ Contemplacao do Consorcio
	M->VVA_SMFVIA := FG_CalcMF({ {FG_RtDtCV("SGV","",M->VV0_DATMOV),M->VVA_SEGVIA} })
	M->VVA_VMFASS :=FG_CalcMF({ {FG_RtDtCV("ASS","",M->VV0_DATMOV),M->VVA_VALASS} })
	if cTipFat == "2"
		M->VVA_VMFFRE := FG_CalcMF({ {FG_RtDtCV("FVD","",M->VV0_DATMOV),M->VVA_VALFRE} })
	Else
		M->VVA_VMFFRE := FG_CalcMF({ {FG_RtDtCV("FVD","",VVF->VVF_DATMOV),M->VVA_VALFRE} })
	Endif
	M->VVA_AMFIMP := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_ASSIMP} })
	M->VVA_VMFREV := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_VALREV} })
	M->VVA_DMFFIX := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_DESFIX} })
	M->VVA_COMPAT := 0   //Comissao de Patio
	M->VVA_CMFPAT := 0   //Comissao de Patio
Endif
M->VVA_BMFFAB := FG_CalcMF({ {M->VVA_DATBFB,M->VVA_BONFAB} })
If M->VVA_INPCBF == "1"
	aPisCof := CalcPisCofSai(M->VVA_BONFAB)
	M->VVA_PISBFB   := aPisCof[1,1] + aPisCof[1,2] //(M->VVA_BONFAB * nAliPis) + (M->VVA_BONFAB * nAliCof)
	M->VVA_PMFBFB   := FG_CalcMF({ {FG_RtDtImp("PIS",M->VVA_DATBFB),M->VVA_PISBFB} })
Endif
If M->VVA_INISBF == "1"
	M->VVA_ISSBFB   := M->VVA_BONFAB * nAliIss
	M->VVA_IMFBFB   := FG_CalcMF({ {FG_RtDtImp("ISS",M->VVA_DATBFB),M->VVA_BONFAB * nAliIss} })
Endif
M->VVA_RMFCUS := FG_CalcMF({ {M->VVA_DATRCU,M->VVA_REDCUS} })
M->VVA_DMFCLI := FG_CalcMF({ {M->VVA_DATDCL,M->VVA_DESCLI} })
M->VVA_RMFTEC := FG_CalcMF({ {M->VVA_DATRTC,M->VVA_RECTEC} })
M->VVA_DMFVEI := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_DESVEI} })
M->VVA_RMFVEI := FG_CalcMF({ {M->VV0_DATMOV,M->VVA_RECVEI} })

If cTipFat == "2" // Faturamento Direto
	M->VVA_VCAVEI := 0
	M->VVA_VMFVEI := 0
	M->VVA_JUREST := 0
	M->VVA_JMFEST := 0
	M->VVA_ALIPIC := M->VVA_ALIPIC
	M->VVA_ALIIPI := M->VVA_ALIIPI
	M->VVA_VRENET := M->VVA_VRENET
	M->VVA_PERCVD := M->VVA_PERCVD
	M->VVA_FATTOT := M->VVA_VALCVD+M->VVA_COMCOT+M->VVA_COMCTP+M->VVA_RECTEC+M->VVA_BONFAB
	M->VVA_FMFTOT := M->VVA_VMFCVD+M->VVA_CMFCOT+M->VVA_CMFCTP+M->VVA_RMFTEC+M->VVA_BMFFAB
Else
	M->VVA_FATTOT := M->VVA_VALMOV+M->VVA_COMCOT+M->VVA_COMCTP+M->VVA_RECTEC+M->VVA_BONFAB
	M->VVA_FMFTOT := M->VVA_VMFMOV+M->VVA_CMFCOT+M->VVA_CMFCTP+M->VVA_RMFTEC+M->VVA_BMFFAB
Endif

M->VVA_TOTIMP := M->VVA_ICMVEN+M->VVA_ISSCVD+M->VVA_PISVEN+M->VVA_COFVEN+M->VVA_ISSRTE+M->VVA_PISRTE+M->VVA_ISSBFB+M->VVA_PISBFB
M->VVA_TMFIMP := M->VVA_IMFVEN+M->VVA_IMFCVD+M->VVA_PMFVEN+M->VVA_CMFVEN+M->VVA_IMFRTE+M->VVA_PMFRTE+M->VVA_IMFBFB+M->VVA_PMFBFB

if cTipFat == "2"
	M->VVA_TOTCUS := FG_FORMULA(GetMv("MV_TOTCUFD"))  //M->VVA_VCAVEI-M->VVA_REDCUS+M->VVA_JUREST+M->VVA_ACESSO+M->VVA_VDESCO+M->VVA_PISENT+M->VVA_COFENT
	M->VVA_TMFCUS := FG_FORMULA(GetMv("MV_TMFCUFD"))  //M->VVA_VMFVEI-M->VVA_RMFCUS+M->VVA_JMFEST+M->VVA_AMFSSO+M->VVA_VMFSCO+M->VVA_PMFENT+M->VVA_CMFENT
Else
	M->VVA_TOTCUS := FG_FORMULA(GetMv("MV_TOTCUFN"))  //M->VVA_VCAVEI-M->VVA_REDCUS+M->VVA_JUREST+M->VVA_VALFRE+M->VVA_ACESSO+M->VVA_VDESCO+M->VVA_PISENT+M->VVA_COFENT
	M->VVA_TMFCUS := FG_FORMULA(GetMv("MV_TMFCUFN"))  //M->VVA_VMFVEI-M->VVA_RMFCUS+M->VVA_JMFEST+M->VVA_VMFFRE+M->VVA_AMFSSO+M->VVA_VMFSCO+M->VVA_PMFENT+M->VVA_CMFENT
Endif

//M->VVA_LUCBRU := M->VVA_FATTOT-M->VVA_TOTIMP-M->VVA_TOTCUS
//M->VVA_LMFBRU := M->VVA_FMFTOT-M->VVA_TMFIMP-M->VVA_TMFCUS

M->VVA_LUCBRU := M->VVA_FATTOT-M->VVA_TOTIMP-M->VVA_VCAVEI-M->VVA_VALFRE  //LUCRO BRUTO
M->VVA_LMFBRU := M->VVA_FMFTOT-M->VVA_TMFIMP-M->VVA_VMFVEI-M->VVA_VMFFRE

if cTipFat == "2"
	M->VVA_TOTDES := M->VVA_DESVEI+M->VVA_DESCLI+M->VVA_SEGVIA+M->VVA_VALASS+M->VVA_VALREV+M->VVA_VALFRE+M->VVA_ASSIMP+M->VVA_DESFIX
	M->VVA_TMFDES := M->VVA_DMFVEI+M->VVA_DMFCLI+M->VVA_SMFVIA+M->VVA_VMFASS+M->VVA_VMFREV+M->VVA_VMFFRE+M->VVA_AMFIMP+M->VVA_DMFFIX
Else
	M->VVA_TOTDES := M->VVA_DESVEI+M->VVA_DESCLI+M->VVA_SEGVIA+M->VVA_VALASS+M->VVA_VALREV+M->VVA_ASSIMP+M->VVA_DESFIX
	M->VVA_TMFDES := M->VVA_DMFVEI+M->VVA_DMFCLI+M->VVA_SMFVIA+M->VVA_VMFASS+M->VVA_VMFREV+M->VVA_AMFIMP+M->VVA_DMFFIX
Endif

//M->VVA_LUCLQ1 := M->VVA_LUCBRU-M->VVA_TOTDES+M->VVA_RECVEI
//M->VVA_LMFLQ1 := M->VVA_LMFBRU-M->VVA_TMFDES+M->VVA_RMFVEI

M->VVA_LUCLQ1 := M->VVA_LUCBRU-M->VVA_JUREST-M->VVA_ACESSO-M->VVA_VDESCO-M->VVA_DESCLI-M->VVA_SEGVIA-M->VVA_VALASS-M->VVA_VALREV-M->VVA_DESVEI-M->VVA_ASSIMP-M->VVA_COMVDE-M->VVA_COMGER-M->VVA_COMPAT //LUCRO MARGINAL
M->VVA_LMFLQ1 := M->VVA_LMFBRU-M->VVA_JMFEST-M->VVA_AMFSSO-M->VVA_VMFSCO-M->VVA_DMFCLI-M->VVA_SMFVIA-M->VVA_VMFASS-M->VVA_VMFREV-M->VVA_DMFVEI-M->VVA_AMFIMP-M->VVA_CMFVDE-M->VVA_CMFGER-M->VVA_CMFPAT //LUCRO MARGINAL

//M->VVA_LUCLQ2 := M->VVA_LUCLQ1-M->VVA_VALIRF-M->VVA_COMVDE-M->VVA_COMGER-M->VVA_COMPAT
//M->VVA_LMFLQ2 := M->VVA_LMFLQ1-M->VVA_VMFIRF-M->VVA_CMFVDE-M->VVA_CMFGER-M->VVA_CMFPAT

M->VVA_LUCLQ2 := M->VVA_LUCLQ1-M->VVA_DESFIX+(M->VVA_REDCUS+M->VVA_RECVEI-M->VVA_DSPFIN)
M->VVA_LMFLQ2 := M->VVA_LMFLQ1-M->VVA_DMFFIX+(M->VVA_RMFCUS+M->VVA_RMFVEI-M->VVA_DMFFIN)

if M->VV0_OPEMOV == "0" .or. Inclui     //Operacao de Venda ou Inclusao
	M->VVA_USUARI := Upper(Subs(cUsuario,7,15))
Endif

// Gerencial
dbSelectArea("VVG")
dbSetOrder(1)
dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)

nCustoVeiculo := 0
if cTipFat == "0"
	If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
		nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
	ElseIf !Empty(VE4->VE4_FORCUS)   //Parametros da Montadora
		nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
	Endif
	if ValType(nCustoVeiculo) <> "N"
		nCustoVeiculo := 0
	Endif
Else
	cFor := GetMv("MV_VUCGER")
	if !Empty(cFor)
		nCustoVeiculo := FG_FORMULA(cFor)
		if ValType(nCustoVeiculo) <> "N"
			nCustoVeiculo := 0
		Endif
	Endif
Endif

if nCustoVeiculo <= 0
	dbSelectArea("VVG")
	dbSetOrder(1)
	if dbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)
		nCustoVeiculo := VVG->VVG_VCNVEI
	Endif
Endif

dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
		if VVD->VVD_ATUCUS=="1"
			nCustoVeiculo += VVD->VVD_VALOR
		Endif
		dbSelectArea("VVD")
		dbSkip()
	Enddo
Endif

dbSelectArea("VVA")

M->VVA_VCAVEI := nCustoVeiculo

Return ( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ATUACESS    ³ Autor ³  Andre           ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza a variavel cGruite utilizada na Avaliacao          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ATUACESS(lRefaz)
Local y := 0

if lRefaz == Nil
	lRefaz := .f.
Endif

If  nParamet == 0
	cGruite := M->VV6_GRUITE
Else
	cGruite := M->VVT_GRUITE
Endif

if ReadVar() == "M->VVT_VALEQP" .or. ReadVar() == "M->VVT_CODITE" .or. ReadVar() == "M->VVT_CODOPC" .or. lRefaz
	
	nValEqp := 0
	
	For y := 1 to len(aCols)
		if aCols[y,Len(aCols[y])]
			Loop
		Endif
		if y = n
			if ReadVar() == "M->VVT_CODITE"
				nValEqp += aCols[y,FG_POSVAR("VVT_VALEQP")]
			Else
				nValEqp += M->VVT_VALEQP
			Endif
		Else
			nValEqp += aCols[y,FG_POSVAR("VVT_VALEQP")]
		Endif
	Next
	
	//Atualiza Tela de Dados do Veiculo
	M->VVA_ACESSO := nValEqp
	oAcesso:Refresh()
	
	//	nCusAce := if(M->VVA_VCAVEI==0,FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase) + nValEqp, M->VVA_VCAVEI + nValEqp)
	If M->VVA_VCAVEI==0
		nCusAce := VVG->VVG_VCNVEI + nValEqp
	Else
		nCusAce := M->VVA_VCAVEI + nValEqp
	Endif
	
	if cEstoque == "S"
		//		FS_FISREF("IT_VALMERC" ,M->VVA_VALVDA+nValEqp)
		FS_FISREF("IT_VALMERC" ,M->VVA_VALVDA)
		FS_FISREF("IT_DESPESA" ,M->VV0_DESACE)
		FS_FISREF("IT_DESCONTO",M->VVA_VALDES)
		
		M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	Else
		//		M->VVA_VALMOV := M->VVA_VALVDA+nValEqp
		M->VVA_VALMOV := M->VVA_VALVDA
	Endif
	oValMov:Refresh()
	
	if cTipFat == "2"
		M->VVA_VBAICM := 0
		M->VVA_ICMVEN := 0
		nTotEnt := M->VVA_VALCVD
	Else
		if cEstoque == "S"
			M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
			M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		Endif
		nTotEnt := M->VVA_VALMOV
	Endif
	
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALVDA      ³ Autor ³  Andre           ³ Data   24/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o preco sugerido para venda                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALVDA(lLucro)

Local nValor := 0

Default lLucro := .f.

//Preco do Modelo
if VV1->VV1_ESTVEI == "0" //Veiculo Novo
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	
	&& Levanta preco atual da tabela.
	VVP->(dbSetOrder(1))
	VVP->(dbSeek(xFilial("VVP")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+Dtos(dDataBase),.t.))
	
	If VVP->VVP_FILIAL+VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == xFilial("VVP")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD ;
		.And. VVP->VVP_DATPRC >= dDataBase
		
		nValor := VVP->VVP_VALTAB
		//Acrescimo p/ valores Metalicos e Perolizados
		Do Case
			Case VVC->VVC_TIPCOR == "1"
				nValor += VVP->VVP_VACRMT
			Case VVC->VVC_TIPCOR == "2"
				nValor += VVP->VVP_VACRPR
		EndCase
		//Acrescimo dos Acessorios do Modelo
		dbSelectArea("VVM")
		dbSetOrder(1)
		if dbSeek(xFilial("VVM")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD)
			While !EOF() .and. VVM->VVM_CODMAR == M->VV1_CODMAR .and. VVM->VVM_MODVEI == M->VV1_MODVEI .and. VVM->VVM_SEGMOD == M->VV1_SEGMOD
				dbSelectarea("VVW")
				dbSeek(xFilial("VVW")+VV1->VV1_CODMAR+VVM->VVM_CODOPC)
				dbSelectArea("SB1")
				dbSetOrder(7)
				dbSeek(xFilial("SB1")+VVW->VVW_GRUITE+VVW->VVW_CODITE)
				nValor += SB1->B1_PRV1
				dbSelectArea("VVM")
				dbSkip()
			Enddo
		Endif
	Endif
Endif

if lLucro
	VV2->(dbSetOrder(1))
	if VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		if VV1->VV1_ESTVEI == "0" //Novo
			if VV2->VV2_LUCNOV > 0
				nValor += ((nValor * VV2->VV2_LUCNOV) / 100)
			Endif
		Else
			if VV2->VV2_LUCUSA > 0
				nValor += ((nValor * VV2->VV2_LUCUSA) / 100)
			Endif
		Endif
	Endif
	
	if VV1->VV1_ESTVEI == "0" //Novo
		if VV2->VV2_LUCNOV == 0
			nValor += (nValor * GetMv("MV_LUCNOV") / 100)
		Endif
	Else
		if VV2->VV2_LUCUSA == 0
			nValor += (nValor * GetMv("MV_LUCUSAD") / 100)
		Endif
	Endif
Endif

if nValor == 0
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+SB1->B1_COD)
	nValor := SB2->B2_VATU1
Endif

Return(nValor)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CLICK       ³ Autor ³  Andre           ³ Data   24/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controla o filtro da consulta                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CLICK(lChecked,nCheck)

Do Case
	Case nCheck == 0
		if lChecked
			cbxCodMar:nClrPane := CLR_HGRAY
			cbxGruMod:nClrPane := CLR_HGRAY
			cbxModVei:nClrPane := CLR_HGRAY
			cCodMar := ""
			if cTipFat == "0"  //Novo
				cCodMar := aMarca[oLbxSel1:nAt,1]
			Endif
			cGruMod := ""
			cModVei := ""
			lVar1 := .t.
			lVar2 := .t.
			oChk1:refresh()
			oChk2:refresh()
		Else
			oLbxSel1:nClrPane := CLR_WHITE
			oLbxSel2:nClrPane := CLR_WHITE
			oLbxSel3:nClrPane := CLR_WHITE
			cCodMar := aMarca[oLbxSel1:nAt,1]
			cGruMod := aGener[oLbxSel2:nAt,1]
			cModVei := aEspec[oLbxSel3:nAt,1]
			lVar1 := .f.
			lVar2 := .f.
			oChk1:refresh()
			oChk2:refresh()
		Endif
	Case nCheck == 1
		if lChecked
			oLbxSel1:nClrPane := CLR_WHITE
			oLbxSel2:nClrPane := CLR_HGRAY
			oLbxSel3:nClrPane := CLR_HGRAY
			cCodMar := aMarca[oLbxSel1:nAt,1]
			cGruMod := ""
			cModVei := ""
			lVar2 := .t.
			oChk2:refresh()
		Else
			oLbxSel1:nClrPane := CLR_WHITE
			oLbxSel2:nClrPane := CLR_WHITE
			oLbxSel3:nClrPane := CLR_WHITE
			cCodMar := aMarca[oLbxSel1:nAt,1]
			cGruMod := aGener[oLbxSel2:nAt,1]
			cModVei := aEspec[oLbxSel3:nAt,1]
			lVar2 := .f.
			oChk2:refresh()
		Endif
	Case nCheck == 2
		if lChecked
			oLbxSel1:nClrPane := CLR_WHITE
			oLbxSel2:nClrPane := CLR_WHITE
			oLbxSel3:nClrPane := CLR_HGRAY
			cCodMar := aMarca[oLbxSel1:nAt,1]
			cGruMod := aGener[oLbxSel2:nAt,1]
			cModVei := ""
		Else
			oLbxSel1:nClrPane := CLR_WHITE
			oLbxSel2:nClrPane := CLR_WHITE
			oLbxSel3:nClrPane := CLR_WHITE
			cCodMar := aMarca[oLbxSel1:nAt,1]
			cGruMod := aGener[oLbxSel2:nAt,1]
			cModVei := aEspec[oLbxSel3:nAt,1]
		Endif
EndCase

FS_FILTROVV()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CHILDOPC    ³ Autor ³  Andre           ³ Data   24/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controla os acessorios do veiculo                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHILDOPC(nPos)

Local aOpcTmp := {}
Local aColsSlv := aclone(acols)
Local aHeaderSlv := aclone(aheader)
Local ix,_ni,y,i := 0

aCols   := aClone(aColsEq)
aHeader := aClone(aHeaderEq)

if Substr(aOpc[nPos,2],4,1) == ">"
	aCols   := aclone(acolsslv)
	aHeader := aclone(aheaderslv)
	Return(.f.)
Endif

if MsgYesNo(OemToAnsi(STR0279),OemToAnsi(STR0015))
	For ix:=1 to Len(aCols)
		if aCols[ix,FG_POSVAR("VVT_CODOPC","aHeaderEq")] == aOpc[nPos,1]
			MsgInfo(OemToAnsi(STR0280),OemToAnsi(STR0015))
			aCols   := aclone(acolsslv)
			aHeader := aclone(aheaderslv)
			Return(.f.)
		Endif
	Next
	
	if Empty(aCols[n,FG_POSVAR("VVT_TIPREG","aHeaderEq")])
		aCols[n,FG_POSVAR("VVT_TIPREG","aHeaderEq")] := "1"
		aCols[n,FG_POSVAR("VVT_CODOPC","aHeaderEq")] := aOpc[nPos,1]
		
		dbSelectArea("VVW")
		dbSetOrder(1)
		dbSeek(xFilial("VVW")+VV1->VV1_CODMAR+aOpc[nPos,1])
		aCols[n,FG_POSVAR("VVT_VALEQP","aHeaderEq")] := VVW->VVW_VALOPC
		
		if VVW->VVW_OPCSER == "0"
			aCols[n,FG_POSVAR("VVT_GRUITE","aHeaderEq")] := VVW->VVW_GRUITE
			aCols[n,FG_POSVAR("VVT_CODITE","aHeaderEq")] := VVW->VVW_CODITE
		Endif
		
		aColsEq := aClone(aCols)
	Else
		aAdd(aColsEq,Array(nUsadoEq+1))
		aColsEq[Len(aColsEq),nUsadoEq+1]:=.F.
		For _ni:=1 to nUsadoEq
			aColsEq[Len(aColsEq),_ni]:=CriaVar(aHeaderEq[_ni,2])
		Next
		aCols := aClone(aColsEq)
		
		aCols[Len(aCols),FG_POSVAR("VVT_TIPREG","aHeaderEq")] := "1"
		aCols[Len(aCols),FG_POSVAR("VVT_CODOPC","aHeaderEq")] := aOpc[nPos,1]
		
		dbSelectArea("VVW")
		dbSetOrder(1)
		dbSeek(xFilial("VVW")+VV1->VV1_CODMAR+aOpc[nPos,1])
		aCols[Len(aCols),FG_POSVAR("VVT_VALEQP","aHeaderEq")] := VVW->VVW_VALOPC
		
		if VVW->VVW_OPCSER == "0"
			aCols[Len(aCols),FG_POSVAR("VVT_GRUITE","aHeaderEq")] := VVW->VVW_GRUITE
			aCols[Len(aCols),FG_POSVAR("VVT_CODITE","aHeaderEq")] := VVW->VVW_CODITE
		Endif
		
		aColsEq := aClone(aCols)
	Endif
	
	nValEqp := 0
	
	For y := 1 to len(aCols)
		if aCols[y,Len(aCols[y])]
			Loop
		Endif
		if y = n
			if ReadVar() == "M->VVT_CODITE"
				nValEqp += aCols[y,FG_POSVAR("VVT_VALEQP")]
			Else
				nValEqp += M->VVT_VALEQP
			Endif
		Else
			nValEqp += aCols[y,FG_POSVAR("VVT_VALEQP")]
		Endif
	Next
	
	//Atualiza Tela de Dados do Veiculo
	M->VVA_ACESSO := nValEqp
	oAcesso:Refresh()
	
	nCusAce := if(M->VVA_VCAVEI==0,FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase) + nValEqp, M->VVA_VCAVEI + nValEqp)
	
	if cEstoque == "S"
		FS_FISREF("IT_VALMERC" ,M->VVA_VALVDA+nValEqp)
		FS_FISREF("IT_DESPESA" ,M->VV0_DESACE)
		FS_FISREF("IT_DESCONTO",M->VVA_VALDES)
		
		M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	Else
		M->VVA_VALMOV := M->VVA_VALVDA+nValEqp
	Endif
	oValMov:Refresh()
	
	if cTipFat == "2"
		M->VVA_VBAICM := 0
		M->VVA_ICMVEN := 0
		nTotEnt := M->VVA_VALCVD
	Else
		if cEstoque == "S"
			M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
			M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
		Endif
		nTotEnt := M->VVA_VALMOV
	Endif
	
Endif

For i:=1 to nPos
	aadd(aOpcTmp,{aOpc[i,1],aOpc[i,2],aOpc[i,3],aOpc[i,4]})
Next

lFaz := .f.
if nPos < Len(aOpc)
	if Substr(aOpc[nPos+1,2],4,1) == ">"
		lFaz := .t.
		For i:=nPos+1 to Len(aOpc)
			if Substr(aOpc[i,2],4,1) == ">" .and. lFaz
				Loop
			Else
				lFaz := .f.
			Endif
			aadd(aOpcTmp,{aOpc[i,1],aOpc[i,2],aOpc[i,3],aOpc[i,4]})
		Next
	Endif
Endif

if !lFaz
	dbSelectArea("VVY")
	dbSetOrder(1)
	dbSeek(xFilial("VVY")+VV1->VV1_CODMAR+aOpc[nPos,1])
	While !Eof() .and. VVY->VVY_CODMAR == VV1->VV1_CODMAR .and. VVY->VVY_CODOPC == aOpc[nPos,1]
		aadd(aOpcTmp,{aOpc[nPos,1],"   > "+VVY->VVY_SEQUEN+" - "+VVY->VVY_DESDET,0,0})
		dbSelectArea("VVY")
		dbSkip()
	EndDo
	
	For i:=nPos+1 to Len(aOpc)
		aadd(aOpcTmp,{aOpc[i,1],aOpc[i,2],aOpc[i,3],aOpc[i,4]})
	Next
Endif

aOpc := aClone(aOpcTmp)

oLbxOpc:SetArray(aOpc)
oLbxOpc:bLine := { || { aOpc[oLbxOpc:nAt,02] ,;
aOpc[oLbxOpc:nAt,03] ,;
aOpc[oLbxOpc:nAt,04] }}
olbxOpc:Refresh()

oGetDados:oBrowse:Refresh()

aCols   := aclone(acolsslv)
aHeader := aclone(aheaderslv)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CHILDSER    ³ Autor ³  Andre           ³ Data   24/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controla os acessorios do veiculo                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHILDSER(nPos)

Local aSerTmp := {}
Local i := 0

if Substr(aSerie[nPos,2],4,1) == ">"
	Return(.f.)
Endif

For i:=1 to nPos
	aadd(aSerTmp,{aSerie[i,1],aSerie[i,2]})
Next

lFaz := .f.
if nPos < Len(aSerie)
	if Substr(aSerie[nPos+1,2],4,1) == ">"
		lFaz := .t.
		For i:=nPos+1 to Len(aSerie)
			if Substr(aSerie[i,2],4,1) == ">" .and. lFaz
				Loop
			Else
				lFaz := .f.
			Endif
			aadd(aSerTmp,{aSerie[i,1],aSerie[i,2]})
		Next
	Endif
Endif

if !lFaz
	dbSelectArea("VVY")
	dbSetOrder(1)
	dbSeek(xFilial("VVY")+VV1->VV1_CODMAR+aSerie[nPos,1])
	While !Eof() .and. VVY->VVY_CODMAR == VV1->VV1_CODMAR .and. VVY->VVY_CODOPC == aSerie[nPos,1]
		aadd(aSerTmp,{aSerie[nPos,1],"   > "+VVY->VVY_SEQUEN+" - "+VVY->VVY_DESDET})
		dbSelectArea("VVY")
		dbSkip()
	EndDo
	
	For i:=nPos+1 to Len(aSerie)
		aadd(aSerTmp,{aSerie[i,1],aSerie[i,2]})
	Next
Endif

aSerie := aClone(aSerTmp)

oLbxSerie:SetArray(aSerie)
oLbxSerie:bLine := { || { aSerie[oLbxSerie:nAt,02] }}
oLbxSerie:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_SIMULAFIN   ³Autor  ³Andre             ³Data: 16.10.2001 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Simula Financiamento do veiculo                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SIMULAFIN()

Local oCodFin, oValorFin, oValorEnt
Local cCodFin   := Space(4)
Local nValorFin := if(nTotEnt>0,nTotEnt,0)
Local nValorEnt := 0

Private oParcelas, oDias, oIndice, oTotal
Private nParcelas := 0
Private nDias     := 0
Private nIndice   := 0
Private nTotal    := 0

aFinan := {{ctod(""),0}}
nOpca  := 0
DEFINE MSDIALOG oDlgFinan TITLE OemtoAnsi(STR0281) FROM  02,04 TO 30,60 OF oMainWnd //Tipo de Faturamento

@ 012,002 SAY OemToAnsi(STR0282) SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 018,002 msget oCodFin  VAR cCodFin Picture "@!" F3 "SEN" VALID (Empty(cCodFin) .or. ExistCpo("SEN",cCodFin)) SIZE 30,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 012,036 SAY OemToAnsi(STR0283) SIZE 50,08   OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 018,036 msget oValorFin  VAR nValorFin Picture "@E 999,999,999.99"  SIZE 60,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 012,100 SAY OemToAnsi(STR0284) SIZE 50,08   OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 018,100 msget oValorEnt  VAR nValorEnt Picture "@E 999,999,999.99"  SIZE 60,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 018,160 BUTTON oObserv PROMPT OemToAnsi(STR0285) OF oDlgFinan SIZE 26,11 PIXEL  ACTION (FS_CALFINAN(cCodFin,nValorEnt,nValorFin))
@ 018,190 BUTTON oObserv PROMPT OemToAnsi(STR0286) OF oDlgFinan SIZE 26,11 PIXEL  ACTION (FS_APAGAFIN())

@ 032,002 SAY OemToAnsi(STR0287) SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 032,030 SAY oParcelas VAR nParcelas SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 032,045 SAY OemToAnsi(STR0288) SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 032,083 SAY oDias VAR nDias SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 032,106 SAY OemToAnsi(STR0289) SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 032,124 SAY oIndice VAR nIndice SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 032,156 SAY OemToAnsi(STR0290) SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLUE
@ 032,180 SAY oTotal VAR nTotal SIZE 50,08 OF oDlgFinan PIXEL COLOR CLR_BLACK

@ 044,001 LISTBOX oLbxFinan FIELDS HEADER  OemToAnsi(STR0291),OemToAnsi(STR0292);
COLSIZES 050,080 SIZE 220,165 OF oDlgFinan PIXEL

oLbxFinan:SetArray(aFinan)
oLbxFinan:bLine := { || { aFinan[oLbxFinan:nAt,01] ,;
aFinan[oLbxFinan:nAt,02] }}

ACTIVATE MSDIALOG oDlgFinan CENTER ON INIT EnchoiceBar(oDlgFinan,{||nOpca := 1,oDlgFinan:End()},{||nOpca := 2,oDlgFinan:End()})

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CALFINAN    ³ Autor ³  Manoel          ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a simulacao de um financiamento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALFINAN(cCodigo,nEntrada,nValor)

Local aParcelas := {}
Local i := 0

if !Empty(cCodigo)
	dbSelectArea("SEN")
	if dbSeek(xFilial("SEN")+cCodigo)
		
		nCoef     := sen->en_coef
		nParcelas := sen->en_maxparc
		nCare     := sen->en_carenc
		nRazao    := sen->en_razao
		nBase     := 0.00
		nVdesc    := 0.00
		nBase     := (nValor-nEntrada-nVdesc)
		nVrpar    := Val(TransForm(nCoef  * nBase,"999999999.99"))
		nTotfin   := nVrpar * nParcelas
		dVenini   := dDataBase  + nCare
		nTotal    := 0
		for i := 1 to nParcelas
			Aadd(aParcelas,{dVenini,nVrpar})
			dVenini := dVenini + nRazao
			nTotal  += nVrpar
		next
		
		nIndice := nCoef
		nDias   := nRazao
		nTotal  := Transform(nTotal,"@E 999,999,999.99")
		aFinan := aClone(aParcelas)
		oLbxFinan:SetArray(aFinan)
		oLbxFinan:bLine := { || { aFinan[oLbxFinan:nAt,01] ,;
		TransForm(aFinan[oLbxFinan:nAt,02],"@E 999,999,999.99") }}
		oLbxFinan:Refresh()
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_APAGAFIN    ³ Autor ³  Manoel          ³ Data   19/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apaga a simulacao de um financiamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_APAGAFIN()

aFinan := {{cTod(""),0}}

oLbxFinan:SetArray(aFinan)
oLbxFinan:bLine := { || { aFinan[oLbxFinan:nAt,01] ,;
aFinan[oLbxFinan:nAt,02] }}
oLbxFinan:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CANCSAI³ Autor ³  Manoel               ³ Data ³ 14/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancelamento de Saidas                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCSAI(cAlias, nReg, nOpc)

Local bCampo 		:= { |nCPO| Field(nCPO) }
Local aMata520Cab := {} , aMata410Cab := {} , aMata410Itens := {}
Local nCntFor,_ni := 0
cTipFat := VV0->VV0_TIPFAT
if cParPrg == "2" // Proposta
	if Empty(VV0->VV0_NUMPED) .and. VV0->VV0_OPEMOV == "1"
		if cTipFat <> "2" .or. (cTipFat == "2" .and. M->VVA_EMINVD == "1") //Faturamento Direto
			MsgInfo(STR0198,STR0199)
			Return(.f.)
		Endif
	Endif
Endif

cCodCli := VV0->VV0_CODCLI
cLojaCli:= VV0->VV0_LOJA
dDatMov := VV0->VV0_DATMOV
nValVei := VV0->VV0_VALMOV
nVBaIcm := VV0->VV0_VBAICM
nTotIcm := VV0->VV0_TOTICM
nAliIcm := VV0->VV0_ALIICM
VVA->(dbSetOrder(1))
VVA->(dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA))
cChassi := VVA->VVA_CHASSI
cChaInt := VVA->VVA_CHAINT
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI))
cNomCli := SA1->A1_NOME

Lin    := 13
nOpca  := 0
cTitle := STR0201

If cParprg == "2"                 // Proposta/Simulacao
	if VV0->VV0_OPEMOV # "1"       // Simulacao
		cTitle := STR0202
	Endif
ElseIf cParPrg == "3"             // Nota Fiscal/Proposta
	if Empty(VV0->VV0_NUMNFI)     // Proposta
		cTitle := STR0203
	Else // Nota Fiscal
		cTitle := STR0112
	Endif
Endif

dbSelectArea("VV0")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("VVA")
dbSeek(xFilial("VVA")+M->VV0_NUMTRA)
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS9")
aHeaderC:= {}
nUsadoC := 0
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for alteracao traz valores digitados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsC   := {}
aIteParc := {}
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+M->VV0_NUMTRA+"V") .and. cTipFat != "2"
	While !Eof() .and. VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VV0->VV0_NUMTRA+'V'
		If VS9->VS9_TIPPAG == "DP"  //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG)
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,08))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,02)
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
			AADD(aColsC,Array(nUsadoC+1))
			For _ni:=1 to nUsadoC
				aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
			Next
			aColsC[Len(aColsC),nUsadoC+1]:=.F.
		Endif
		dbSkip()
	Enddo
Endif

if Len(aColsC) == 0
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Endif

if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif

if cTipSai <> "4"  //Devolucao
	
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(cTitle) FROM  4.5,0 To 36,80 OF oMainWnd
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI))
	cNomCli := SA1->A1_NOME
	cEndCli := SA1->A1_END
	cCGCCPF := SA1->A1_CGC
	if SA1->A1_TIPO == "F"
		cPicture := "@R 999.999.999.99"
	Else
		cPicture := "@R 99.999.999/9999-99"
	Endif
	
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
	cDesFpg := alltrim(SE4->E4_DESCRI)
	SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3")+M->VV0_CODVEN))
	cNomVen := SA3->A3_NOME
	VV1->(dbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1")+M->VVA_CHAINT))
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	cDesMar := VE1->VE1_DESMAR
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	cDesCor := VVC->VVC_DESCRI
	
	M->VV0_DATMOV := dDataBase
	if VV0->VV0_TIPFAT == "0"
		cDesTpV := OemToAnsi(STR0178)
	Elseif VV0->VV0_TIPFAT == "1"
		cDesTpV := OemToAnsi(STR0179)
	Elseif VV0->VV0_TIPFAT == "2"
		cDesTpV := OemToAnsi(STR0180)
	Endif
	
	@ Lin,004 SAY OemToAnsi(STR0150)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //Pedido
	@ Lin,068 SAY M->VV0_NUMPED OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	@ Lin,160 SAY OemToAnsi(STR0151)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //Data
	@ Lin,224 SAY M->VV0_DATMOV OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	Lin += 9
	@ Lin,004 SAY STR0204 OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK
	Lin += 6
	@ Lin,005 TO lin+2,310 LABEL "" OF oDlg PIXEL  //Linha Separadora
	Lin += 6
	@ Lin,004 SAY OemToAnsi(STR0051)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //Cliente
	@ Lin,068 SAY oNomCli VAR cNomCli OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	@ Lin,198 SAY OemToAnsi(STR0094)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //Loja
	@ Lin,224 SAY M->VV0_LOJA OF oDlg PIXEL FONT oFnt4  COLOR CLR_RED
	Lin += 9
	@ Lin,004 SAY OemToAnsi(STR0205)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //Endereco
	@ Lin,068 SAY cEndCli OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK
	@ Lin,184 SAY OemToAnsi(STR0206)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //CNPJ/CPF
	@ Lin,224 SAY Transform(cCGCCPF,cPicture) SIZE 100,08 OF oDlg PIXEL FONT oFnt3 COLOR CLR_BLACK
	Lin += 9
	@ Lin,004 SAY STR0207 OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK
	Lin += 6
	@ Lin,005 TO lin+2,310 LABEL "" OF oDlg PIXEL  //Linha Separadora
	Lin += 6
	@ Lin,004 SAY OemToAnsi(STR0088)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE  //Chassi
	@ Lin,068 Say M->VVA_CHASSI OF oDlg PIXEL  FONT oFnt4  COLOR CLR_RED
	@ Lin,183 SAY OemToAnsi(STR0057)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE  //Vendedor
	@ Lin,224 SAY cNomVen OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	Lin := lin + 9
	@ Lin,004 SAY OemToAnsi(STR0063)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE  //Marca
	@ Lin,068 SAY cDesMar OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	Lin := lin + 9
	@ Lin,004 SAY OemToAnsi(STR0064) OF odlg PIXEL FONT oFnt4 COLOR CLR_BLUE   //Modelo
	@ Lin,068 SAY VV1->VV1_MODVEI OF oDlg PIXEL  FONT oFnt4  COLOR CLR_RED
	Lin := lin + 9
	@ Lin,004 SAY  OemToAnsi(STR0065)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE //Cor
	@ Lin,068 SAY cDesCor OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	Lin += 9
	@ Lin,004 SAY STR0208 OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK
	Lin += 6
	@ Lin,005 TO lin+2,310 LABEL "" OF oDlg PIXEL  //Linha Separadora
	Lin += 6
	
	If VV0->VV0_TIPFAT == "2"
		nTotEnt := M->VVA_VALCVD
	Else
		nTotEnt := M->VVA_VALMOV
	Endif
	
	//Forma de Pagamento
	cTipPag := M->VV0_FORPAG
	
	nc          := 1
	nLinhas     := 99
	aHeader     := aClone(aHeaderC)
	aCols       := aClone(aColsC)
	oGetCondicao:= MsGetDados():New(Lin,004,Lin+62,310,2,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,99,"AllwaysTrue()",,,,oDlg)
	oGetCondicao:oBrowse:default()
	
	Lin += 65
	@ Lin,200 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0144),OemToAnsi(STR0155);
	COLSIZES 40,50;
	SIZE 110,061 OF oDlg PIXEL
	
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}
	
	Lin += 5
	@ Lin,004 SAY OemToAnsi(STR0154) OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE
	@ Lin,070 SAY oValMov VAR Trans(M->VVA_VALMOV,"@E 99,999,999.99") SIZE 60,08 OF oDlg PIXEL FONT oFnt3 COLOR CLR_BLACK
	Lin += 9
	@ Lin,004 SAY OemToAnsi(STR0054)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLUE
	@ Lin,078 SAY cDesFpg OF oDlg PIXEL FONT oFnt4 COLOR CLR_RED
	Lin += 12
	Do Case
		Case cParPrg == "3"  //Faturamento
			if !Empty(VV0->VV0_NUMNFI)
				@ Lin,004 SAY OemToAnsi(STR0209)        OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK //Serie
				@ Lin,048 SAY FGX_UFSNF(VV0->VV0_SERNFI) OF oDlg PIXEL FONT oFnt3 COLOR CLR_RED
				Lin += 9
				@ Lin,004 SAY OemToAnsi(STR0210)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK //Nota Fiscal
				@ Lin,048 SAY VV0->VV0_NUMNFI OF oDlg PIXEL FONT oFnt3  COLOR CLR_RED
			Else
				Lin += 9
			Endif
		Case cParPrg == "2"  //Proposta/Pedido
			if !Empty(VV0->VV0_NUMPED)
				@ Lin,004 SAY OemToAnsi(STR0211)  OF oDlg PIXEL FONT oFnt4 COLOR CLR_BLACK //Pedido
				@ Lin,048 SAY VV0->VV0_NUMPED OF oDlg PIXEL FONT oFnt3 COLOR CLR_RED
			Endif
			Lin += 9
	EndCase
	
	Lin += 20
	@ Lin,004 SAY cDesTpV OF oDlg PIXEL FONT oFnt7 COLOR CLR_BLACK
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 2,oDlg:End()})
Else
	nOpca := 1
Endif

if nOpca == 1
	lAbortPrint := .f.
	Processa( {|| FS_GRACAN() }," "," ",.t. )
Endif


if FunName() == "VEIVM010"
	dbSelectArea("VV0")
	Eval(bFiltraBrw)
Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GRACAN ³ Autor ³  Manoel               ³ Data ³ 27/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava Cancelamento                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRACAN()

Local aRegSD2 := {}
Local aRegSE1 := {}
Local aRegSE2 := {}
Local nCont    := 0
Local lDeleta  := .f.
Local aParcTit := {}
Local aParcelas:= {}
Local cTipCob  := if(!Empty(cCodBco).or.!Empty(VV0->VV0_CODBCO),"1","0")
Local i := 0

if Empty(cCodBco)
	cCodBco := VV0->VV0_CODBCO
Endif

lMsHelpAuto := .f.

lDeleta := .t.

if cParPrg <> "1" .and. VV0->VV0_TIPFAT == "2" //Faturamento Direto
	
	If VV0->VV0_SITNFI == "1" // Valida
		
		if cParPrg == "2"
			if Empty(VV0->VV0_NUMPED)
				if M->VVA_EMINVD == "1" //Faturamento Direto
					Help(" ",1,"PEDNEMITID")
					Return .f.
				Endif
			Endif
		Endif
		
		VVA->(dbSetOrder(1))
		if !VVA->(dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA))
			Help(" ",1,"ARQITEINCO")
			Return .f.
		Endif
		
		VV1->(dbSetOrder(1))
		if !VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHAINT))
			Help(" ",1,"VEINFNEXCD")
			Return
		Endif
		
		if  cParPrg # "2"
			if VV1->VV1_SITVEI # "1"    //Vendido
				Help(" ",1,"SITVEIM010")
				Return
			Endif
		Endif
		
		If VV0->VV0_OPEMOV # "0"       //Venda
			Help(" ",1,"NFINVCANCE")
			Return
		Endif
		
		if !Empty(VV0->VV0_NUMNFI)
			if !MsgYesNo(OemToAnsi(STR0113),OemToAnsi(STR0015))
				Help(" ",1,"NEXCFATDIR")
				Return
			Endif
		Endif
	Else
		if cParPrg == "2"
			Help(" ",1,"PEINVCANCE")
			Return
		Else
			Help(" ",1,"NFINVCANCE")
			Return
		Endif
	Endif
Endif

lMsHelpAuto := .t.
lMsErroAuto := .f.

Begin Transaction

if cParPrg <> "1" // Simulacao
	
	If VV0->VV0_SITNFI == "1" // Valida
		
		VVA->(dbSetOrder(1))
		if !VVA->(dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA))
			Help(" ",1,"ARQITEINCO")
			DisarmTransaction()
			Break
		Endif
		
		VV1->(dbSetOrder(1))
		if !VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHAINT))
			Help(" ",1,"VEINFNEXCD")
			DisarmTransaction()
			Break
		Endif
		
		If Alltrim(cTipSai) == "0"     //Venda
			If VV0->VV0_OPEMOV # "0"
				Help(" ",1,"NFINVCANCE")
				DisarmTransaction()
				Break
			Endif
		Elseif Alltrim(cTipSai) == "2"  //Transferencia
			If VV0->VV0_OPEMOV # "2"
				Help(" ",1,"NFINVCANCE")
				DisarmTransaction()
				Break
			Endif
		Elseif Alltrim(cTipSai) == "3" //Remessa
			If VV0->VV0_OPEMOV # "3"
				Help(" ",1,"NFINVCANCE")
				DisarmTransaction()
				Break
			Endif
		Endif
		
		if !Empty(VV0->VV0_NUMNFI) .and. (cTipFat <> "2" .or. (cTipFat == "2" .and. M->VVA_EMINVD == "1"))   //Faturamento Direto
			
			cNumTit := ""
			dbSelectArea("VE4")
			dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
			if VE4->VE4_GTPRFT  == "0" // Gera titulo na Proposta
				cNumTit := Right(M->VV0_NUMTRA,9)
				cPrefNF := "PRP"
			Else  // Gera titulo no Faturamento
				cNumTit := VV0->VV0_NUMNFI
			Endif
			
			aMata410Cab   := {{"C5_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do pedido SC5
			aMata410Itens := {{"C6_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do Pedido SC6
			
			/*
			if (cParPrg ="2" .and. VV0->VV0_AUTFAT == "1") .or. cParPrg == "3"
			//Exclusao da Nota Fiscal
			aMata520Cab   := {{"F2_DOC"  ,VV0->VV0_NUMNFI ,Nil},; //numero da nota
			{"F2_SERIE",VV0->VV0_SERNFI ,Nil}}  //serie
			ProcRegua(1)
			IncProc(STR0214)
			If lAbortPrint
			If MsgYesNo(OemToAnsi(STR0215),OemToAnsi(STR0199))
			Help("  ",1,"M160PROABO")
			lRet := .f.
			DisarmTransaction()
			Break
			Else
			lAbortPrint := .F.
			EndIf
			EndIf
			cKey := aMata520Cab[1,2]+aMata520Cab[2,2]
			SF2->(dbSetOrder(1))
			if SF2->(dbSeek(xFilial("SF2")+cKey))
			MSExecAuto({|x| Mata520(x)},aMata520Cab)
			If lMsErroAuto
			Help(" ",1,"ERROCANCNF") // Erro ao Cancelar a Nota Fiscal
			DisarmTransaction()
			Break
			Endif
			Endif
			Endif
			*/
			
			dbSelectArea("SF2")
			dbSetOrder(1)
			If dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o estorno do documento de saída pode ser feito     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
					/*Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2, Array com os registro do SE1, Array com os registro do SE2 ) */
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna o documento de saida                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PERGUNTE("MTA521",.f.)
					SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
				Else
					//Nao pode ser excluida.
					lMsErroAuto:= .T.
					Return(.f.)
				EndIf
			Endif
			
			//Exclui Pedido
			ProcRegua(1)
			IncProc(STR0216)
			If lAbortPrint
				If MsgYesNo(OemToAnsi(STR0217),OemToAnsi(STR0199))
					Help("  ",1,"M160PROABO")
					lRet := .f.
					DisarmTransaction()
					Break
				Else
					lAbortPrint := .F.
				EndIf
			EndIf
			
			SC9->(dbSetOrder(1))
			SC9->(dbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
			While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
				SC9->(a460Estorna())
				SC9->(dbSkip())
			EndDo
			
			//Cancela o Pedido
			cKey := aMata410Cab[1,2]
			SC5->(dbSetOrder(1))
			if SC5->(dbSeek(xFilial("SC5")+cKey))
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
				If lMsErroAuto
					Help(" ",1,"ERROCANCPD") // Erro ao Cancelar o Pedido
					DisarmTransaction()
					Break
				Endif
			Endif
			
			cNumTit := ""
			dbSelectArea("VE4")
			dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
			if VE4->VE4_GTPRFT  == "0" // Gera titulo na Proposta
				cNumTit := Right(M->VV0_NUMTRA,9)
				cPrefNF := "PRP"
			Else  // Gera titulo no Faturamento
				cNumTit := VV0->VV0_NUMNFI
			Endif
			
			dbSelectArea("SE1")
			dbSetOrder(1)
			if dbSeek(xFilial("SE1")+cPrefNF+cNumTit)
				While ! Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == cNumTit
					
					AADD(aParcelas,{{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
					{"E1_NUM"     ,E1_NUM     ,nil},;
					{"E1_PARCELA" ,E1_PARCELA ,nil},;
					{"E1_TIPO"    ,E1_TIPO    ,nil},;
					{"E1_NATUREZA",E1_NATUREZA,nil},;
					{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
					{"E1_LOJA"    ,E1_LOJA    ,nil},;
					{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
					{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
					{"E1_VENCREA" ,E1_VENCREA ,nil},;
					{"E1_VALOR"   ,E1_VALOR   ,nil},;
					{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
					{"E1_DATABOR" ,E1_DATABOR ,Nil},;
					{"E1_PORTADO" ,E1_PORTADO ,Nil},;
					{"E1_SITUACA" ,E1_SITUACA ,Nil},;
					{"E1_ORIGEM" , "MATA460"  ,nil}})
					dbSelectArea("SE1")
					dbSkip()
				Enddo
				pergunte("FIN040",.F.)
				For i = 1 to len(aParcelas)
					MSExecAuto({|x,y| FINA040(x,y)},aParcelas[i],5)
					if lMsErroAuto
						Help(" ",1,"ERREXCLTIT") // Erro na Exclusao do Titulo do Contas a Receber
						DisarmTransaction()
						Break
					Endif
				Next
				
				dbSelectArea("VSE")
				If dbSeek(xFilial("VSE")+VV0->VV0_NUMTRA+'V')
					while VSE->VSE_FILIAL+VSE->VSE_NUMIDE+VSE->VSE_TIPOPE == xFilial("VSE")+VV0->VV0_NUMTRA+"V" .and. !eof()
						if !RecLock("VSE",.f.,.t.)
							Help("  ",1,"REGNLOCK")
							DisarmTransaction()
							Break
						Endif
						DbDelete()
						MsUnlock()
						WriteSx2("VSE")
						dbSkip()
					Enddo
				Endif
				
				dbSelectArea("VS9")
				If dbSeek(xFilial("VS9")+VV0->VV0_NUMTRA+'V')
					while VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+VV0->VV0_NUMTRA+"V" .and. !eof()
						RecLock("VS9",.f.,.t.)
						DbDelete()
						MsUnlock()
						WriteSx2("VS9")
						dbSkip()
					Enddo
				Endif
				
			Endif
		Endif
		
		// Fim do Cancelamento dos Titulos a Receber
		
		dbSelectArea("VV1")
		RecLock("VV1",.f.)
		// Faturamento Direto
		if VV0->VV0_TIPFAT == "2"
			VV1->VV1_SITVEI := " "
			VV1->VV1_NUMTRA := Space(10)
		Else
			if cTipSai == "6" // Retorno da Entrada por Remessa
				VV1->VV1_SITVEI := "3"   //No Estoque (Poder de Terceiro)
			Else
				VV1->VV1_SITVEI := "0"   //Estoque
			Endif
			VV1->VV1_NUMTRA := Space(10)
			VV1->VV1_DTHRES := Space(17)
			VV1->VV1_DTHVAL := Space(17)
		Endif
		MsUnlock()
		
		if cTipSai == "6" // Retorno da Entrada por Remessa
			dbSelectArea("VVF")
			dbSetOrder(1)
			if dbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
				RecLock("VVF",.f.)
				VVF->VVF_SITNFI := "1"
				MsUnlock()
			Endif
		Endif
		
		dbSelectArea("VVA")
		RecLock("VVA",.f.)
		VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
		MsUnlock()
		
		dbSelectArea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "0" //Cancelada
		VV0->VV0_DATUSU := DtoS(dDataBase)+"-"+__cUserID
		if VV0->VV0_OPEMOV == "0"
			VV0->VV0_OPEMOV := "1"
		Endif
		VV0->VV0_NUMPED := ""
		VV0->VV0_NUMNFI := ""
		VV0->VV0_SERNFI := ""
		if fieldpos('VV0_SDOC') > 0
			VV0->VV0_SDOC := ""
		EndIf
		VV0->VV0_TRADEV := ""
		MsUnlock()
		
		dbSelectArea("VE4")
		dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
		if cParPrg == "2" .and. VE4->VE4_GTPRFT  == "0" // Gera titulo na Proposta
			FS_APAGACOM()
		Elseif (cParPrg == "3" .and. VE4->VE4_GTPRFT  == "1") .or. (VV1->VV1_CODMAR <> VE4->VE4_PREFAB)   // Gera titulo no Faturamento
			FS_APAGACOM()
		Endif
		
	Elseif VV0->VV0_SITNFI == "2" // NF de Devolucao
		
		aMata410Cab   := {{"C5_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do pedido SC5
		aMata410Itens := {{"C6_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do Pedido SC6
		aMata520Cab   := {{"F2_DOC"      , VV0->VV0_NUMNFI ,Nil},; //numero da nota
		{"F2_SERIE"    , VV0->VV0_SERNFI ,Nil}}  //serie
		
		ProcRegua(1)
		IncProc(STR0220)
		If lAbortPrint
			If MsgYesNo(OemToAnsi(STR0221),OemToAnsi(STR0199))
				Help("  ",1,"M160PROABO")
				lRet := .f.
				DisarmTransaction()
				Break
			Else
				lAbortPrint := .F.
			EndIf
		EndIf
		
		MSExecAuto({|x| Mata520(x)},aMata520Cab) // Cancela NF
		If lMsErroAuto
			Help(" ",1,"ERROCANCNF") // Erro ao Cancelar a Nota Fiscal
			DisarmTransaction()
			Break
		Endif
		
		//Exclui Pedido
		
		ProcRegua(1)
		IncProc(STR0222)
		If lAbortPrint
			If MsgYesNo(OemToAnsi(STR0223),OemToAnsi(STR0199))
				Help("  ",1,"M160PROABO")
				lRet := .f.
				DisarmTransaction()
				Break
			Else
				lAbortPrint := .F.
			EndIf
		EndIf
		
		SC9->(dbSetOrder(1))
		SC9->(dbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
		While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
			SC9->(a460Estorna())
			SC9->(dbSkip())
		EndDo
		
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5) //Cancela Pedido
		
		If lMsErroAuto
			Help(" ",1,"ERROCANCPD")     //Nao Conformidade ao Cancelar o Pedido
			DisarmTransaction()
			Break
		Endif
		
		dbSelectArea("VV0")
		if !RecLock("VV0",.f.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		VV0->VV0_SITNFI := "2"    //Devolvida
		VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
		
		dbSelectArea("VVF")
		dbSetOrder(5)
		dbSeek(xFilial("VVF")+VV0->VV0_NUMTRA)
		RecLock("VVF",.f.)
		VVF->VVF_SITNFI := "1"    //Valida
		VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
		
		dbSelectArea("VVA")
		dbSetOrder(1)
		dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
		RecLock("VV1",.f.)
		VV1->VV1_SITVEI := "0"   //Estoque
		MsUnlock()
	Else
		if cParPrg == "2"
			Help(" ",1,"PEINVCANCE")
			DisarmTransaction()
			Break
		Else
			Help(" ",1,"NFINVCANCE")
			DisarmTransaction()
			Break
		Endif
	Endif
Endif

if cParPrg == "1" .or. lDeleta
	VM110DELNEG()  // Exclui Negociacao de Pagamento
	FS_APAGSIMUL() // Apaga Registros de Veiculos
Endif

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock() 

If lMsErroAuto
	MostraErro()
	lMSHelpAuto := .f.
	lMSErroAuto := .f.
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |VM110DELNEG |Autor  ³Ricardo Farinelli   | Data ³03/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Exclui a negociacao para poder incluir as novas negociacoes º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gestao de Concessionarias                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM110DELNEG()

Local lAchou
Local _Fil  := xFilial("VS9")

dbSelectArea("VSE")
dbSeek(xfilial("VSE")+VV0->VV0_NUMTRA+'V')
While !Eof() .and. xFilial("VSE") == VSE->VSE_FILIAL .and. VSE->VSE_NUMIDE == VV0->VV0_NUMTRA .and. VSE->VSE_TIPOPE == "V"
	if RecLock("VSE",.f.,.t.)
		VSE->(dbDelete())
		MsUnlock()
		WriteSx2("VSE")
	Endif
	dbSkip()
Enddo

dbSelectArea("VS9")
lAchou:= dbSeek(xFilial("VS9")+VV0->VV0_NUMTRA)
Do While (_Fil+VV0->VV0_NUMTRA)== (VS9_FILIAL+VS9_NUMIDE) .and. !Eof()
	Reclock("VS9",.F.)
	Dbdelete()
	MsUnlock()
	VS9->(dbSkip())
Enddo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_VALIDOP³Autor  ³Valdir              ³ Data ³  27/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do codigo do opcional                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Veiculos                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function V010VLDOPC(lLimpa)

Local lRet := .f.
Local nX

Default lLimpa := .F.

If !lLimpa
	If FG_SEEK("VVW","VV1->VV1_CODMAR+M->VVT_CODOPC",1,.f.) .and.;
		FG_SEEK("VVM","VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+VVW->VVW_CODOPC",1,.f.)
		aCols[n,FG_POSVAR("VVT_GRUITE","aHeader")] := VVW->VVW_GRUITE
		aCols[n,FG_POSVAR("VVT_CODITE","aHeader")] := VVW->VVW_CODITE
		aCols[n,FG_POSVAR("VVT_DESITE","aHeader")] := VVW->VVW_DESOPC
		M->VVT_GRUITE                              := VVW->VVW_GRUITE
		M->VVT_CODITE                              := VVW->VVW_CODITE
		M->VVT_DESITE                              := VVW->VVW_DESOPC
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Else
	lRet := .T.
	For nX := 1 to Len(aCols[n])-1
		If Trim(Upper(aHeader[nX,2]))	# "VVT_TIPREG"
			aCols[n,nX] := CriaVar(aHeader[nX,2])
		EndIf
	Next
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VM010ALPRC³Autor  ³Valdir              ³ Data ³  27/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera o valor de um campo/variavel de acordo com a formula º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Veiculos                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM010ALPRC(cFormula,cCampo)

Local nPreco := FG_Formula(&cFormula)

M->&cCampo := nPreco
aCols[n,FG_POSVAR(cCampo)] := nPreco

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CHASSI³ Autor ³ Andre                 ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Chassi do Veiculo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHASSI(cNT)

Local lRet := .t.

dbSelectArea("VVA")
dbSetOrder(1)
if dbSeek(xFilial("VVA")+cNT)
	if Empty(VVA->VVA_CHASSI)
		lRet := .f.
	Endif
Endif
dbSelectArea("VV0")

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FS_APAGACOM |Autor  ³Andre               | Data ³28/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Exclui a comissao gerada do vendedor no caso de cancelamentoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gestao de Concessionarias                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_APAGACOM()

dbSelectArea("VSG")
dbSetOrder(1)
if dbSeek(xFilial("VSG")+VV0->VV0_NUMTRA+"V"+VV0->VV0_CODVEN)
	while !eof() .and. VSG->VSG_NOSNUM == VV0->VV0_NUMTRA .and. VSG->VSG_TIPCOM == "V" .and. VSG->VSG_CODVEN == VV0->VV0_CODVEN
		RecLock("VSG",.f.,.t.)
		dbDelete()
		MsUnlock()
		writeSx2("VSG")
		dbSkip()
	enddo
Endif

Return


Function FS_ATRSX3(cCampo)

Local lRet := .t.

dbSelectArea("SX3")
dbSetOrder(2)
if dbSeek(cCampo)
	if !(&x3_valid)
		lRet := .f.
	Endif
Endif

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INTLOJA³ Autor ³Andre                  ³ Data ³ 09/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz integracao da venda balcao c/ o sigaloja					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Siga Veiculos (Modulo de Oficina/Pecas)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INTVLOJA()

Local aCabPV  := Array(17)
Local aItePV  := {}
Local aPagPV  := {}
Local cLoc    := Space(15)
Local nX
Local cOrcLoja
Local cCliPad := ""
Local cLojPad := ""
Local cEstVAM
if lA1_IBGE
	FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
	cEstVAM := VAM->VAM_ESTADO
else
	cEstVAM := SA1->A1_EST
endif

If VV0->VV0_TIPFAT == "1" .and. cEstVAM <> GETMV("MV_ESTADO") //veiculo usado usa a aliquota interna
	cCliPad  := GetMv("MV_CLIPAD")
	cLojPad := GetMv("MV_LOJAPAD")
Endif
//Cabecalho
aCabPV[01] := SA1->A1_COD     //Codigo do cliente
aCabPV[02] := SA1->A1_LOJA    //Loja para entrada
aCabPV[03] := M->VV0_CODVEN   //Codigo do vendedor
aCabPV[04] := dDataBase+30    //Data de emissao
aCabPV[05] := 0    		       //Valor do ICMS
aCabPV[06] := 0               //Valor do ISS
aCabPV[07] := 0               //Valor do IPI
aCabPV[08] := 0               //Valor do Desconto
aCabPV[09] := nTotEnt         //Valor Liquido(Total-Desconto)
aCabPV[10] := "3"             //Quem esta gravando
aCabPV[11] := VV0->VV0_NUMTRA //Chave a pesquisar
aCabPV[12] := cTipPag
aCabPV[13] := cClipad
aCabPV[14] := cLojPad
aCabPV[15] := 0
aCabPV[16] := 0
aCabPV[17] := 0

//Pega a classificacao fiscal de acordo com o estado do cliente
cCFiscal := FG_CLAFIS(M->VVA_CODTES)

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	dbSelectArea("SBF")
	dbSetOrder(2)
	if dbSeek(xFilial("SBF")+SB1->B1_COD+SB1->B1_LOCPAD)
		if Localiza(SB1->B1_COD)
			cLoc := SBF->BF_LOCALIZ
		Endif
	Endif
	
	Aadd(aItePV,Array(20))
	aItePV[Len(aItePV),01] := SB1->B1_COD                    //Codigo do Produto
	aItePV[Len(aItePV),02] := SB1->B1_DESC                   //Descricao do Produto
	aItePV[Len(aItePV),03] := 1                              //Quantidade Vendida
	aItePV[Len(aItePV),04] := M->VVA_VALMOV-M->VVA_VALDES   //Valor Unitario
	aItePV[Len(aItePV),05] := M->VVA_VALMOV-M->VVA_VALDES   //Valor Total do Item
	aItePV[Len(aItePV),06] := SB1->B1_LOCPAD                //Almoxarifado
	aItePV[Len(aItePV),07] := 	SB1->B1_UM                    //Unidade de Medida Primaria.
	aItePV[Len(aItePV),08] := (M->VVA_VALDES/M->VVA_VALMOV)*100   		                     //Desconto percentual
	aItePV[Len(aItePV),09] := M->VVA_VALDES                 //Desconto Valor
	aItePV[Len(aItePV),10] := M->VVA_CODTES                 //Tipo de Saida do Item
	aItePV[Len(aItePV),11] := cCFiscal                      //CFO
	aItePV[Len(aItePV),12] := 0                             //Valor IPI
	aItePV[Len(aItePV),13] := M->VVA_ICMVEN                 //Valor do ICMS
	aItePV[Len(aItePV),14] := 0                             //Valor do ISS
	aItePV[Len(aItePV),15] := M->VVA_VBAICM                 //Base ICMS
	aItePV[Len(aItePV),16] := M->VVA_VALMOV                 //Valor Unitario
	aItePV[Len(aItePV),17] := ""                            //Lote
	aItePV[Len(aItePV),18] := ""                            //Sub Lote
	aItePV[Len(aItePV),19] := cLoc                          //Localizacao
	aItePV[Len(aItePV),20] :=	""                            //Numero de Serie
	
	//Entradas
	For nX:=1 to Len(aColsC)
		If !aColsC[nX,Len(aColsC[nX])] .and. !Empty(aColsC[nX,1])
			Aadd(aPagPV,Array(4))
			aPagPV[Len(aPagPV),01] := aColsC[nX,3]
			aPagPV[Len(aPagPV),02] := aColsC[nX,4]
			aPagPV[Len(aPagPV),03] := aColsC[nX,1]
			aPagPV[Len(aPagPV),04] := ""
		Endif
	Next
	
	For nX:=1 to Len(aIteParc)
		If !Empty(aIteParc[nX,1])
			Aadd(aPagPV,Array(4))
			aPagPV[Len(aPagPV),01] := DataValida(aIteParc[nX,1])
			aPagPV[Len(aPagPV),02] := aIteParc[nX,2]
			aPagPV[Len(aPagPV),03] := "DP"
			aPagPV[Len(aPagPV),04] := ""
		EndIf
	Next
	
	Asort(aPagPV,,,{|x,y| dtos(x[1])+descend(x[3]) < dtos(y[1])+descend(y[3]) })
	
	FG_GRVLOJA(aCabPV,aItePV,aPagPV,.F.,@cOrcLoja)
	
	if ValType(cOrcLoja) == "C"
		RecLock("VV0",.f.)
		VV0->VV0_PESQLJ := cOrcLoja
		MsUnlock()
	Endif
Endif

Return( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ALIICMS³ Autor ³ Andre                 ³ Data ³ 11/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda aliquota de ICMS dependendo do estado do cliente p/    ³±±
±±³          ³veiculos novos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALIICMS(cCodB1)

/*
Local aAreaSB1 := GetArea("SB1")
Local nAliq    := if(VV1->VV1_ESTVEI == "0",VVA->VVA_ALIICM,0) //Veiculo Novo

if cTipSai $ "23" //Transferencia ou Remessa
nAliq := VVA->VVA_ALIICM
Endif

dbSelectArea("SB1")
dbSetOrder(1)
if dbSeek(xFilial("SB1")+cCodB1)
RecLock("SB1",.f.)
SB1->B1_PICM := nAliq
MsUnlock()
Endif

SB1->(RestArea(aAreaSB1))
*/

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FICHA  ºAutor  ³Fabio               º Data ³  09/19/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica ficha curricular                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FICHA()

Local nVar     := 0
Local aFicha   := {}
Local oFont    := TFont():New( "Courier New", 7, 15 )
Private nOp_   := 2

if Empty(M->VVA_CHAINT)
	MsgInfo(STR0373 ,STR0015) //Nenhum Veiculo foi selecionado! - Atencao !
	Return .f.
Endif

nOp_ := 2
DEFINE MSDIALOG oDlFicha TITLE OemtoAnsi(STR0333) FROM  01,01 TO 28,80 OF oMainWnd //ficha curricular

//ListBox da Ficha Curricular
@ 012,.1 LISTBOX oLbxFicha FIELDS HEADER OemToAnsi(STR0374) SIZE 312,191 OF oDlFicha FONT oFont PIXEL //Historico

FS_FICCUR010(@aFicha)

oLbxFicha:SetArray(aFicha)
oLbxFicha:bLine := { || { aFicha[oLbxFicha:nAt,1] } }

ACTIVATE MSDIALOG oDlFicha CENTER ON INIT (FG_ENCHOICEBAR(oDlFicha,{|| nOp_ := 1, oDlFicha:End()},{|| nOp_ := 2, oDlFicha:End()}))

if nOp_ == 2
	Return .f.
Endif

Return


Function FS_FICCUR010(aFicha)

Local dDataOld := Ctod("  /  /  ")

aFicha := {}

dbSelectArea("VFB")
dbSetOrder(9)
dbSeek( xFilial("VFB") + M->VVA_CHAINT + Dtos( dDataBase - GetMv("MV_FICAOS") ) , .t. )

Do While !Eof() .And. VFB->VFB_FILIAL+VFB->VFB_CHAINT+Dtos(VFB->VFB_DATAPL) >= xFilial("VFB") + M->VVA_CHAINT + Dtos( dDataBase - GetMv("MV_FICAOS") ) ;
	.And. VFB->VFB_FILIAL+VFB->VFB_CHAINT+Dtos(VFB->VFB_DATAPL) <= xFilial("VFB") + M->VVA_CHAINT + Dtos( dDataBase )
	
	If dDataOld # VFB->VFB_DATAPL
		
		If Len(aFicha) # 0
			aAdd( aFicha , {""} )
		EndIf
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+VFB->VFB_CODCLI+VFB->VFB_LOJA)
		
		aAdd( aFicha , {""} )
		aFicha[Len(aFicha),1] += STR0375 + Space(1) + Dtoc( VFB->VFB_DATAPL ) + Space(1)   //Dt Aplic:
		aFicha[Len(aFicha),1] += STR0376 + Space(1) + Dtoc( VFB->VFB_DATFEC ) + Space(1)   //Dt Fecha
		aFicha[Len(aFicha),1] += STR0377 + Space(1) + VFB->VFB_CODCLI + Space(1)  //Cliente:
		aFicha[Len(aFicha),1] += STR0378 + Space(1) + VFB->VFB_LOJA + Space(1)  //Loja:
		aFicha[Len(aFicha),1] += STR0379 + Space(1) + SA1->A1_NOME + Space(1)  //Nome:
		dDataOld := VFB->VFB_DATAPL
		
		aAdd( aFicha , {""} )
		                                                    
		aFicha[Len(aFicha),1] += STR0380 +Space(1)+ STR0381 +Space(2)+ STR0382 +Space(14)+ STR0383 +Space(12)+ STR0384 +Space(3)+ STR0385 +Space(4)+ STR0386   //P/S # Grp # Cod Item/Servico # Descricao # Qtd Aplic # Nro OS # Tp
		
	EndIf
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+VFB->VFB_GRUITE+VFB->VFB_CODITE)
	
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+VFB->VFB_CHAINT)
	
	dbSelectArea("VO6")
	dbSetOrder(2)
	dbSeek(xFilial("VO6")+VV1->VV1_CODMAR+VFB->VFB_CODSER)
	
	aAdd( aFicha , {""} )
	aFicha[Len(aFicha),1] += Space(1)+VFB->VFB_SERPEC+Space(2)
	aFicha[Len(aFicha),1] += VFB->VFB_GRUITE+Space(1)
	If VFB->VFB_SERPEC == "P"
		aFicha[Len(aFicha),1] += VFB->VFB_CODITE+Space(3)
		aFicha[Len(aFicha),1] += Substr( SB1->B1_DESC,1,20)+Space(3)
	Else
		aFicha[Len(aFicha),1] += VFB->VFB_CODSER+Space(15)
		aFicha[Len(aFicha),1] += Substr(VO6->VO6_DESSER,1,20)+Space(3)
	EndIf
	aFicha[Len(aFicha),1] += Transform( VFB->VFB_QTDAPL , "@E 999,999")+Space(3)
	aFicha[Len(aFicha),1] += VFB->VFB_NUMOSV+Space(3)
	aFicha[Len(aFicha),1] += VFB->VFB_TIPTEM+Space(3)
	
	dbSelectArea("VFB")
	dbSkip()
	
EndDo

If Len(aFicha) == 0
	aAdd( aFicha , {""} )
EndIf

Return


/////////////////////
Function FS_FILCONS()

Local lOk  := .t.
Local nLin := 12

DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0185) FROM  02,04 TO 12,86 OF oMainWnd

//Ano Inicial
@ nLin,004 SAY  OemToAnsi(STR0134)  OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,004 MSGET oAnoIni VAR nAnoIni PICTURE "9999" SIZE 28,4  OF oDlgNew PIXEL COLOR CLR_BLACK
//Ano Final
@ nLin,034 SAY OemToAnsi(STR0136) OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,034 MSGET oAnoFin VAR nAnoFIn PICTURE "9999" SIZE 28,4  OF oDlgNew PIXEL COLOR CLR_BLACK

//Combustivel
@ nLin,70 SAY  OemToAnsi(STR0133)  OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,70 MSCOMBOBOX oCombus VAR cCombus SIZE 65,50 COLOR CLR_BLACK ITEMS aCombus OF oDlgNew PIXEL

//Faixa de Preco 1
@ nLin,140 SAY  OemToAnsi(STR0135)  OF oDlgNew PIXEL COLOR CLR_BLUE //Faixa de Valor
@ nLin+10,140 MSGET oValFxI VAR nValFxI PICTURE "@E 999,999.99" SIZE 55,4  OF oDlgNew PIXEL  COLOR CLR_BLACK

//Faixa de Preco 2
@ nLin,200 SAY OemToAnsi(STR0136) OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,200 MSGET oValFxF VAR nValFxF PICTURE "@E 999,999.99" SIZE 55,4  OF oDlgNew PIXEL COLOR CLR_BLACK

//Kilometragem
@ nLin,260 SAY OemToAnsi(STR0137) OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,260 MSGET oKMFxa VAR nKMFxa PICTURE "@E 999,999.99" SIZE 55,4  OF oDlgNew PIXEL COLOR CLR_BLACK

nLin+=23

//Tipo de Cor
@ nLin,002 SAY  OemToAnsi(STR0131)  OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,002 MSCOMBOBOX oTipCor VAR cTipCor SIZE 50,50 COLOR CLR_BLACK ITEMS aTipCor OF oDlgNew PIXEL

//Cor
@ nLin,060 SAY  OemToAnsi(STR0065)  OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,060 MSGET oGruCor VAR cGruCor PICTURE "@!" F3 "VVQ"  SIZE 25,4  OF oDlgNew PIXEL COLOR CLR_BLACK
@ nLin+10,093 SAY cDesGCor OF oDlgNew PIXEL COLOR CLR_BLUE

//Cor Especifica
@ nLin,160 SAY  OemToAnsi(STR0132)  OF oDlgNew PIXEL COLOR CLR_BLUE
@ nLin+10,160 MSGET oCorF VAR cCOR PICTURE "@!" F3 "COR" SIZE 36,4  OF oDlgNew PIXEL  COLOR CLR_BLACK
@ nLin+10,198 SAY Subs(cDesCor,1,14)  OF oDlgNew PIXEL COLOR CLR_BLUE

//Estado do veiculo
@ nLin,265 SAY  OemToAnsi(STR0139)  OF oDlgNew PIXEL COLOR CLR_BLUE  //Estado
@ nLin+10,265 MSCOMBOBOX oEstVeiF VAR cEstVeiF SIZE 50,50 COLOR CLR_BLACK ITEMS aEstVeiF OF oDlgNew PIXEL

nLin+=23

DEFINE SBUTTON oOk1 TYPE 4 FROM nLin,002 OF oDlgNew ENABLE ONSTOP OemToAnsi("Ok") ACTION ()
oOk1:cToolTip := OemToAnsi(STR0058) //OK

ACTIVATE MSDIALOG oDlgNew CENTER ON INIT (FG_ENCHOICEBAR(oDlgNew,{|| lOk := .t.,oDlgNew:End()},{|| lOk := .f.,oDlgNew:End()}))
if lOk
	FS_FILTROVV()
Endif

Return


///////////////////////////
Function FS_INICP010(nTipo)

Local cRet := ""

if nTipo == 1 //Cliente
	if !Inclui
		FG_VALIDA(,"SA1TVV0->VV0_CODCLI+VV0->VV0_LOJA*",,.F.)
	Else
		FG_VALIDA(,"SA1TM->VV0_CODCLI+M->VV0_LOJA*",,.F.)
	Endif
	if	!SA1->(Eof())
		if lA1_IBGE
			FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
		endif
		if alltrim(SX3->X3_CAMPO) == "VV0_NOMCLI"
			cRet := SA1->A1_NOME
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_ENDCLI"
			cRet := SA1->A1_END
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_CIDCLI"
			if lA1_IBGE
				cRet := VAM->VAM_DESCID
			else
				cRet := SA1->A1_MUN
			endif
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_ESTCLI"
			if lA1_IBGE
				cRet := VAM->VAM_ESTADO
			else
				cRet := SA1->A1_EST
			endif
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_FONCLI"
			cRet := SA1->A1_TEL
		Endif
		M->VV0_NOMCLI := SA1->A1_NOME
		M->VV0_ENDCLI := SA1->A1_END
		if lA1_IBGE
			M->VV0_CIDCLI := VAM->VAM_DESCID
			M->VV0_ESTCLI := VAM->VAM_ESTADO
		else
			M->VV0_CIDCLI := SA1->A1_MUN
			M->VV0_ESTCLI := SA1->A1_EST
		endif
		M->VV0_FONCLI := SA1->A1_TEL
	Endif
Else
	if !Inclui
		FG_VALIDA(,"VV1TVV0->VV0_CHAINT*",,.F.)
		//Else
		//   FG_VALIDA(,"VV1T2M->VV0_CHASSI*",,.F.)
	Endif
	if	!VV1->(Eof())
		FG_VALIDA(,"VE1TVV1->VV1_CODMAR*",,.F.)
		if alltrim(SX3->X3_CAMPO) == "VV0_DESMAR"
			cRet := VE1->VE1_DESMAR
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_CODMAR"
			cRet := VV1->VV1_CODMAR
		Endif
		M->VV0_DESMAR := VE1->VE1_DESMAR
		M->VV0_CODMAR := VV1->VV1_CODMAR
		
		FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
		if alltrim(SX3->X3_CAMPO) == "VV0_DESMOD"
			cRet := VV2->VV2_DESMOD
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_CHASSI"
			cRet := VV1->VV1_CHASSI
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_CODFRO"
			cRet := VV1->VV1_CODFRO
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_PLAVEI"
			cRet := VV1->VV1_PLAVEI
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_FABMOD"
			cRet := VV1->VV1_FABMOD
		Endif
		M->VV0_DESMOD := VV2->VV2_DESMOD
		M->VV0_CHASSI := VV1->VV1_CHASSI
		M->VV0_CODFRO := VV1->VV1_CODFRO
		M->VV0_PLAVEI := VV1->VV1_PLAVEI
		M->VV0_FABMOD := VV1->VV1_FABMOD
		
		FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
		if alltrim(SX3->X3_CAMPO) == "VV0_DESCOR"
			cRet := VVC->VVC_DESCRI
		Endif
		M->VV0_DESCOR := VVC->VVC_DESCRI
		
		FG_VALIDA(,"SA1TVV1->VV1_PROATU+VV1->VV1_LJPATU*",,.F.)
		if lA1_IBGE
			FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
		endif
		if alltrim(SX3->X3_CAMPO) == "VV0_PROVEI"
			cRet := SA1->A1_COD
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_LOJAPR"
			cRet := SA1->A1_LOJA
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_NOMPRO"
			cRet := SA1->A1_NOME
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_ENDPRO"
			cRet := SA1->A1_END
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_CIDPRO"
			if lA1_IBGE
				cRet := VAM->VAM_DESCID
			else
				cRet := SA1->A1_MUN
			endif
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_ESTPRO"
			if lA1_IBGE
				cRet := VAM->VAM_ESTADO
			else
				cRet := SA1->A1_EST
			endif
		Endif
		if alltrim(SX3->X3_CAMPO) == "VV0_FONPRO"
			cRet := SA1->A1_TEL
		Endif
		M->VV0_PROVEI := SA1->A1_COD
		M->VV0_LOJAPR := SA1->A1_LOJA
		M->VV0_NOMPRO := SA1->A1_NOME
		M->VV0_ENDPRO := SA1->A1_END
		if lA1_EST
			M->VV0_CIDPRO := VAM->VAM_DESCID
			M->VV0_ESTPRO := VAM->VAM_ESTADO
		else
			M->VV0_CIDPRO := SA1->A1_MUN
			M->VV0_ESTPRO := SA1->A1_EST
		endif
		M->VV0_FONPRO := SA1->A1_TEL
	Else
		M->VV0_DESMAR := ""
		M->VV0_DESMOD := ""
		M->VV0_CHASSI := ""
		M->VV0_CODFRO := ""
		M->VV0_PLAVEI := ""
		M->VV0_FABMOD := ""
		M->VV0_DESCOR := ""
		M->VV0_PROVEI := ""
		M->VV0_LOJAPR := ""
		M->VV0_NOMPRO := ""
		M->VV0_ENDPRO := ""
		M->VV0_CIDPRO := ""
		M->VV0_ESTPRO := ""
		M->VV0_FONPRO := ""
	EndIf
Endif

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TraItCamºAutor  ³Manoel              º Data ³  07/06/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trata delecao e inclusao de itens de campanha               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cPar == D,(qdo deleta ou recupera linha - bDelete)          º±±
±±º          ³cPar == A (qdo chamada pelo FieldOk ou bChange)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fs_TraItCam(cPar)

Local it_

If cPar == "D"
	
	If acols[n,len(acols[n])]
		M->VVA_DESCLI += acols[n,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
	Else
		M->VVA_DESCLI -= acols[n,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
	Endif
	
Else
	
	M->VVA_DESCLI := 0
	for it_ := 1 to Len(aCols)
		If !acols[it_,len(acols[it_])]
			If Readvar() == "M->VZ7_VALITE" .and. it_ == n
				M->VVA_DESCLI += M->VZ7_VALITE
			Else
				M->VVA_DESCLI += acols[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
			Endif
		Endif
	Next
	
Endif

Return .t.

//////////////////////////
Function FS_DADVEI(nPosLb)

Local aArea1 := GetArea()

cNtTerceiro   := ""
cResponsavel  := ""
cProprietario := ""
cCondPgt      := ""
cSituacao     := ""
cTerceiro     := ""
nDiasEst      := 0

dbSelectArea("VV1")
dbSetOrder(2)
if dbSeek(xFilial("VV1")+M->VV1_CHASSI)
	cPlaca := VV1->VV1_PLAVEI
	cKm    := VV1->VV1_KILVEI
	dbSelectArea("SA1")
	dbSetOrder(1)
	if dbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
		cProprietario := alltrim(SA1->A1_NOME)+"   ( "+VV1->VV1_PROATU+" )"
	Endif
	if !Empty(VV1->VV1_TRACPA)
		dbSelectArea("VVF")
		dbSetOrder(1)
		if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
			nDiasEst := (dDataBase-VVF->VVF_DATMOV)
		Endif
		cSituacao := STR0328 //Normal
		cNtTerceiro := VVF->VVF_NUMNFI + " - " + FGX_UFSNF(VVF->VVF_SERNFI) + "    ( "+ STR0387 +" )" //Entrada
		dbSelectArea("SE4")
		dbSetOrder(1)
		if dbSeek(xFilial("SE4")+VVF->VVF_FORPAG)
			cCondPgt := VVF->VVF_FORPAG + " ( " + alltrim(SE4->E4_DESCRI) + " ) "
		Endif
	Endif
	if VV1->VV1_RESERV $ "1/3" // 1 reservado 3 venda futura
		cSituacao := STR0329 //Reservado
	Endif
	
	//Verifica se tem porder de terceiro
	if VV1->VV1_SITVEI == "3" //Remessa
		cSituacao := STR0330 //Remessa
		dbSelectArea("VVF")
		dbSetOrder(1)
		if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
			if VVF->VVF_OPEMOV == "2"
				cNtTerceiro := VVF->VVF_NUMNFI + " - " + FGX_UFSNF(VVF->VVF_SERNFI) + "    ( "+ STR0387 +" )" //Entrada
				if SA1->(dbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA))
					cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VVF->VVF_CODFOR+" )"
				Endif
			Else
				dbSelectArea("VV0")
				dbSetOrder(1)
				if dbSeek(xFilial("VV0")+VV1->VV1_NUMTRA)
					if VV0->VV0_OPEMOV == "3"
						cNtTerceiro := VV0->VV0_NUMNFI + " - " + FGX_UFSNF(VV0->VV0_SERNFI) + "    ( "+STR0336+" )" //saida
						if SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
							cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VV0->VV0_CODCLI+" )"
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	
	if VV1->VV1_SITVEI == "4" //Consignado
		cSituacao := STR0331 //Consignado
		dbSelectArea("VVF")
		dbSetOrder(1)
		if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
			if VVF->VVF_OPEMOV == "4"
				cNtTerceiro := VVF->VVF_NUMNFI + " - " + FGX_UFSNF(VVF->VVF_SERNFI) + "    ( "+ STR0387 +" )" //Entrada
				if SA1->(dbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA))
					cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VVF->VVF_CODFOR+" )"
				Endif
			Else
				dbSelectArea("VV0")
				dbSetOrder(1)
				if dbSeek(xFilial("VV0")+VV1->VV1_NUMTRA)
					if VV0->VV0_OPEMOV == "5"
						cNtTerceiro := VV0->VV0_NUMNFI + " - " + FGX_UFSNF(VV0->VV0_SERNFI) + "    ( "+STR0336+" )" //saida
						if SA1->(dbSeek(xFilial("SA1")+VV0->VVF_CODCLI+VV0->VV0_LOJA))
							cTerceiro := alltrim(SA1->A1_NOME)+"   ( "+VV0->VV0_CODCLI+" )"
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	
Endif

//oProprietario:Refresh()
//oPlaca:Refresh()
//oKm:Refresh()
//oDias:Refresh()
//oCondPgt:Refresh()
//oNtTerceiro:Refresh()
//oTerceiro:Refresh()
//oSituacao:Refresh()

RestArea(aArea1)

Return


//////////////////////////////
Function FS_CORBROWSE(nPosBrw)

Local oCor

if aStruVV1[nPosBrw,2] == "R"
	oCor := oVermelho
Endif
if aStruVV1[nPosBrw,2] == "C"
	oCor := oAzul
Endif
if aStruVV1[nPosBrw,2] == "B"
	oCor := oAmarelo
Endif

Return( oCor )


Function FS_LISTDESP()

Local lRet  := .t.
Local aDesp := {{.f.,"","",0}}

dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	aDesp := {}
	while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
		aadd(aDesp,{if(VVD->VVD_ATUCUS=="1",.T.,.F.),if(VVD->VVD_TIPOPE=="0","D","R"),VVD->VVD_DESCRI,VVD->VVD_VALOR})
		dbSelectArea("VVD")
		dbSkip()
	Enddo
Endif

if Len(aDesp) == 0
	aDesp := {{.f.,"","",0}}
Endif

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0388) FROM  02,04 TO 16,68 OF oMainWnd //Despesas/Receitas do Veiculo

@ 001,001 LISTBOX oLbx1 FIELDS HEADER  OemToAnsi(STR0389),OemToAnsi("T"),OemToAnsi(STR0383),OemToAnsi(STR0390);//custo -descricao - Valor
COLSIZES 30,10,160,50 SIZE 250,90 OF oDlg PIXEL ON DBLCLICK(.t.)
oLbx1:SetArray(aDesp)
oLbx1:bLine := { || {if(aDesp[oLbx1:nAt,01]==.f.,oNo,oTik), aDesp[oLbx1:nAt,02], aDesp[oLbx1:nAt,03], Transform(aDesp[oLbx1:nAt,04],"@E 999,999,999.99") }}

@ 093,001 SAY STR0391 SIZE 250,08 OF oDlg PIXEL COLOR CLR_BLUE  //Se o custo estiver marcado e porque faz parte do custo do veiculo...

ACTIVATE MSDIALOG oDlg CENTER

Return(lRet)


Function axPesqVei()

axPesqui()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no indice da IndRegua                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
Eval(bFiltraBrw)

Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VM010PLEG  ³ Autor ³ Alexandre            ³ Data ³ 11/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse na proposta  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³VEIVM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM010PLEG()
Local aLegenda :=       {{'BR_VERDE'	,STR0406},;  //Disponivel para Alteracao
						 {'BR_VERMELHO'	,STR0392}} //Proposta Finalizada

BrwLegenda(cCadastro,STR0393 ,aLegenda)  //Legenda

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VM010FLEG  ³ Autor ³ Alexandre            ³ Data ³ 11/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse faturamento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³VEIVM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM010FLEG()
Local aLegenda :=       {{'BR_VERDE'	,STR0394},; //Disponivel para Faturamento
						 {'BR_VERMELHO'	,STR0395}} //Faturamento ja Efetuado

BrwLegenda(cCadastro,STR0393 ,aLegenda)//Legenda

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IteCamamºAutor  ³Manoel              º Data ³  07/06/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trata delecao e inclusao de itens de campanha               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cPar == D, Deleta registros do Arquivo VZ7                  º±±
±±º          ³cPar == I, Inclui registros no Arquivo VZ7                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function Fs_AtuVZ7(cPar)

Local itc

DbSelectArea("VZ7")
DbSetOrder(1)

If cPar == "D"
If DbSeek(xFilial("VZ7")+M->VV0_NUMTRA)
while !eof() .and. VZ7->VZ7_FILIAL+VZ7->VZ7_NUMTRA == xFilial("VZ7")+M->VV0_NUMTRA
RecLock("VZ7",.f.,.t.)
DbDelete()
MsUnlock()
WriteSx2("VZ7")
DbSelectArea("VZ7")
DbSkip()
Enddo
Endif
Else // inclusao ou alteracao
DbSelectArea("VZ7")
for itc := 1 to Len(aColsIC)
DbSeek(xFilial("VZ7")+M->VV0_NUMTRA+aColsIC[itc,FG_POSVAR('VZ7_CODACV',"aHeaderIC")]+aColsIC[itc,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")])
If Found()
If acolsIC[itc,len(acolsIC[itc])]
Reclock("VZ7",.f.,.t.)
DbDelete()
MsUnlock()
WriteSx2("VZ7")
Loop
Else
Reclock("VZ7",.f.)
Endif
Else
If !acolsIC[itc,len(acolsIC[itc])]
Reclock("VZ7",.t.)
Else
Loop
Endif
Endif
VZ7->VZ7_FILIAL := xFilial("VZ7")
VZ7->VZ7_NUMTRA := M->VV0_NUMTRA
VZ7->VZ7_CODACV := aColsIC[itc,FG_POSVAR('VZ7_CODACV',"aHeaderIC")]
VZ7->VZ7_ITECAM := aColsIC[itc,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")]
VZ7->VZ7_VALITE := aColsIC[itc,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
MsUnlock()
Next
Endif
*/

Function FS_VMCLI010()
Local lRet := .f.

If FunName() == "VEIVM016"
	//
	SA1->(DbSetOrder(1))
	SA1->(DBSeek(xFilial("SA1")+M->VV0_CODCLI+IIf(!Empty(M->VV0_LOJA),M->VV0_LOJA,"")))
	// Verifica todas as filiais da empresa, menos a propria filial //
	If left(SA1->A1_CGC,8) == left(SM0->M0_CGC,8) .and. SA1->A1_CGC # SM0->M0_CGC
		lRet := .t.
		M->VV0_NOMCLI := SA1->A1_NOME
		M->VV0_ENDCLI := SA1->A1_END
		M->VV0_CIDCLI := SA1->A1_MUN
		M->VV0_ESTCLI := SA1->A1_EST
	Else
		MsgStop(STR0407,STR0015)
	EndIf
	//
	Return(lRet)
EndIf	

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA))
M->VV0_NOMCLI := SA1->A1_NOME
M->VV0_ENDCLI := SA1->A1_END
M->VV0_CIDCLI := SA1->A1_MUN
M->VV0_ESTCLI := SA1->A1_EST

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

Return(.T.)

Function FS_VMVEND010()

M->VV0_NOMVEN := SA3->A3_NOME

Return(.T.)


Function FS_VALMOVTO()

if cTipFat == "2"
	FS_FisRef("IT_VALMERC",M->VVA_VALCVD)
	M->VVA_ISSCVD := MaFisRet(,"NF_VALISS")
Else
	FS_FisRef("IT_VALMERC" ,M->VV0_VALMOV-M->VVA_BONFAB+M->VVA_RECTEC+M->VVA_DESVEI+M->VVA_VALASS+M->VVA_VALREV+M->VVA_ASSIMP+M->VVA_DESFIX+M->VVA_DSPFIN+nValEqp)
Endif
FS_FisRef("IT_DESCONTO",M->VV0_VALDES)
FS_FisRef("IT_DESPESA" ,M->VV0_DESACE+M->VVA_DESCLI)
FS_FisRef("IT_SEGURO"  ,M->VVA_SEGVIA)

M->VV0_VALTOT := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
M->VVA_VALVDA := M->VV0_VALTOT
M->VVA_VALDES := M->VV0_VALDES

If VV0->VV0_TIPFAT == "2"
	M->VVA_VBAICM := 0
	M->VVA_ICMVEN := 0
	M->VVA_ALIICM := 0
	M->VVA_VALCVD := M->VV0_VALTOT
	nTotEnt := M->VVA_VALCVD
Else
	nTotEnt := M->VV0_VALTOT
Endif

if !Empty(M->VVA_CODTES)
	FS_CARTES()
Endif

M->VVA_LUCBRU := M->VV0_VALTOT-M->VVA_TOTIMP-M->VVA_VCAVEI-M->VVA_VALFRE

Return(.t.)


Function FS_CARTES()

Local mvIncent      := GetNewPar("MV_INCENT",0)

//Inicializa as Variaveis Fiscais
If !MaFisFound('NF')
	if Empty(M->VV0_CODCLI)
		Return .t.
	Endif
	if Empty(M->VVA_CODTES)
		Return .t.
	Endif
Endif

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

FS_FisRef("IT_PRODUTO",M->VVA_CHAINT)
FS_FisRef("IT_TES",M->VVA_CODTES)
if !MaAvalTes("S",M->VVA_CODTES)
	Return(.f.)
Endif

if cTipFat == "2"
	M->VVA_VBAICM := 0
	M->VVA_ICMVEN := 0
	M->VVA_ALIICM := 0
Else
	M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
	M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
	if cTipFat == "0"   //Novo
		M->VVA_ALIICM := MaFisRet(1,"IT_ALIQICM")
		if mvIncent <> 0
			M->VVA_ALIICM := 	mvIncent
		Endif
	Elseif cTipFat == "1" //Usado
		M->VVA_ALIICM := MaFisRet(1,"IT_ALIQICM")
	Endif
	
	//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	//Pega a aliquota do Produto, so qdo existir no arquivo VV8
	//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	if SB1->B1_PICM > 0
		M->VVA_ALIICM := SB1->B1_PICM
		FS_FisRef("IT_ALIQICM",M->VVA_ALIICM)
	Endif
	
Endif

if cEstoque == "S" .and. cTipFat <> "2"
	FS_FisRef("IT_DESPESA" ,M->VV0_DESACE)
	FS_FisRef("IT_DESCONTO",M->VV0_VALDES)
	FS_FisRef("IT_ALIQICM" ,M->VVA_ALIICM)
	M->VVA_ALIICM := MaFisRet(1,"IT_ALIQICM")
Endif

if cTipFat == "2"  //Faturamento Direto
	M->VVA_VBAICM := 0
	M->VVA_ICMVEN := 0
	M->VVA_VALCVD := Round(M->VVA_VALCVD,2)
Else
	M->VVA_VBAICM := MaFisRet(,"NF_BASEICM")
	M->VVA_ICMVEN := MaFisRet(,"NF_VALICM")
Endif

Return(.t.)


Function FS_VMVEI010()

M->VVA_CHAINT := VV1->VV1_CHAINT
M->VVA_ESTVEI := if(VV1->VV1_ESTVEI="0",STR0316,STR0317) //novo - usado

M->VV0_CHAINT := VV1->VV1_CHAINT
M->VV0_DESMAR := POSICIONE("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR")
M->VV0_CODMAR := VE1->VE1_CODMAR
M->VV0_DESMOD := POSICIONE("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD")
M->VV0_MODVEI := VV2->VV2_MODVEI
M->VV0_DESCOR := POSICIONE("VVC",1,xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI,"VVC_DESCRI")
M->VV0_CORVEI := VVC->VVC_CORVEI
M->VV0_FABMOD := VV1->VV1_FABMOD
M->VV0_PLAVEI := VV1->VV1_PLAVEI

Return

Function FS_TIPATE()

if M->VV0_SIMULA = "0"
	cParPrg := "2"
Else
	cParPrg := "1"
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FOTO  ³ Autor ³ ANDRE                 ³ Data ³ 14/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe a foto do veiculo que esta no cadastro               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FOTO()

nPos := oLbox:nAt
cKey := aStruVV1[nPos,5]
FG_Seek("VV1","cKey",2,.f.)
if !Empty(VV1->VV1_BITMAP)
	DEFINE MSDIALOG oDlgFoto TITLE STR0320 From 10,0 to 30,44 of oMainWnd  //foto do veiculo
	@ 001, 001 REPOSITORY oBmp NOBORDER SIZE 175, 160 OF oDlgFoto PIXEL ADJUST
	FG_BMP(ALLTRIM(VV1->VV1_BITMAP),"oBmp")
	ACTIVATE MSDIALOG oDlgFoto CENTER
Endif

Return .t.

Static Function MenuDef()
Local aRotina := { {OemtoAnsi(STR0009)  ,"axPesqVei"  , 0 , 1},;   //Pesquisar
{OemtoAnsi(STR0010)	,"FS_SIMVDAT", 0 , 2} ,;    //Consultar
{OemtoAnsi(STR0011)	,"FS_SIMVDAT", 0 , 3} ,;    //Incluir
{OemtoAnsi(STR0013)	,"FS_SIMVDAT", 0 , 4 },;    //Alterar
{OemtoAnsi(STR0183)	,"FS_CANCSAI", 0 , 5 },;    //Excluir
{OemtoAnsi(STR0393)	,"VM010PLEG", 0, 3 ,2,.f.},; //Legenda
{ STR0396 			,"VM010_LVEI" , 0 , 2}}   //Pesquisa Chassi
Return aRotina

Function ve010Icms()

if M->VV0_VALMOV > 0 .and. MaFisFound('NF')
	FS_FisRef("IT_VALMERC",M->VV0_VALMOV)
	FS_FisRef("IT_ALIQICM",M->VV0_ALIICM)
	FS_FisRef("IT_DESPESA",M->VV0_DESACE)
	FS_FisRef("IT_DESCONTO",0)
	if ReadVar() == "M->VV0_ALIICM"
		FS_FisRef("IT_ALIQICM",M->VV0_ALIICM)
	Endif
	M->VVA_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
	if M->VV0_TIPFAT == "2"
		M->VV0_VBAICM := 0
		M->VV0_ICMVEN := 0
	Else
		M->VV0_VBAICM := MaFisRet(,"NF_BASEICM")
		M->VV0_ICMVEN := MaFisRet(,"NF_VALICM")
		M->VV0_TOTICM := MaFisRet(,"NF_VALICM")
	Endif
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM010_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM010_LVEI()
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
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0397) FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
@ 003,004 SAY STR0398 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE //Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0399) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End())//SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0400),;//Filial
OemToAnsi(STR0401),;//Dt.Movimento
OemToAnsi(STR0402),;//Chassi
OemToAnsi(STR0403),;//Vlr Venda
OemToAnsi(STR0404);//Cliente
COLSIZES 10,35,35,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]<>"2",oVerd,oVerm),;
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
Local nNUMNFI := len(VV0->VV0_NUMNFI)
Local nPESQLJ := len(VV0->VV0_PESQLJ)
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_SITNFI , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VV0.VV0_NUMNFI , VV0.VV0_SERNFI FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
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
	cQuery += "VV0.VV0_OPEMOV='0' AND VV0.VV0_NUMNFI='"+space(nNUMNFI)+"' AND VV0.VV0_PESQLJ='"+ space(nPESQLJ)+ "' AND "
	cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV "

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
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_SITNFI ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+FGX_UFSNF(( cQAlVV0 )->( VV0_SERNFI )) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0405 +" "+cLevChas,STR0015) //Nenhuma NF Venda encontrada para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]<>"2",oVerd,oVerm),;
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
