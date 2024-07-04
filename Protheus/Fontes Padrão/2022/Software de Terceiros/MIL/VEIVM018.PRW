// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Veivm010.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM018 ³ Autor ³  Manoel               ³ Data ³ 09/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolucao da ENTRADA de Veiculos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM018
//cCondicao := 'VVF->VVF_SITNFI $ "12" .and. !Empty(VVF->VVF_NUMNFI) .and. !VVF->VVF_OPEMOV $ "26"'
Local aCores := {{'!VVF->VVF_SITNFI $ "123" .or. Empty(VVF->VVF_NUMNFI) .or. VVF->VVF_OPEMOV $ "26"','BR_VERMELHO'},; // nao eh devolucao
{'VVF->VVF_SITNFI $ "1" .and. !Empty(VVF->VVF_NUMNFI) .and. !VVF->VVF_OPEMOV $ "26"','BR_AZUL'},; // Disponivel para Devolucao
{'VVF->VVF_SITNFI $ "3" .and. !Empty(VVF->VVF_NUMNFI) .and. !VVF->VVF_OPEMOV $ "26"','BR_BRANCO'},; // Disponivel para Cancelamento (Devolucao Parcial)
{'VVF->VVF_SITNFI $ "2" .and. !Empty(VVF->VVF_NUMNFI) .and. !VVF->VVF_OPEMOV $ "26"','BR_AMARELO'}} // Disponivel para Cancelamento
Private oLBox
Private nOpca
Private cSerOri
Private cNfiOri
Private cSerie, cNota
Private cIteNFOri
Private ocondic, oGetCondicao, oTotEnt,  oTipPag, oDesPag, oLbParc
Private cCondic1  := ctod(" ")
Private cCondic2  := Space(02)
Private cCondic3  := Space(02)
Private cCondic4  := Space(02)
Private cCondic5  := "1"
Private cNumBord := ""
Private dDatBord := cTod("")
Private lA1_IBGE    := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE    := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
Private lAbortPrint := .f.
Private oFonte      := TFont():New( "Arial", 6, 12 )
Private oFnt6       := TFont():New( "Times New Roman", 7, 17 )
Private cParPrg     := nNumLib := " "
Private oNo         := LoadBitmap( GetResources(), "LBNO" )
Private oTik        := LoadBitmap( GetResources(), "LBTIK" )
Private aStruCha    := aGets := aTela := aEncVVF := {}
Private nAliPis     := 0
Private nAliCof     := 0
Private nValCor     := 0
Private cEstoque    := "S"
Private aMemos    := {{"VVA_OBSMEM","VVA_OBSERV"}}
Private cSitNF      := "2"  // Devolucao
Private cNumLib     := " "  // Para Liberacao de Venda
Private lTroca      := .f. //Troca com Troco
Private cCodCDCI    := Space(4)
Private nValorCom   := 0
Private cIdeSB6     := Space(6)
Private cGruVei     := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private aColsC      := {}
Private aHeaderC    := {}
Private aIteParc    := {}
Private aRotina     := MenuDef()
Private nTotalEnt   := 0  // Rubens - Somente para Compatibilizacao com a VEIVM011
Private cTipOpe     := 3  //Veiculos
Private lTroco      := .f.
Private lParcial    := .f. // Status da NF de Entrada (se .f., TOTAL, se .t., Parcial)

Private lMudouNum := .f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VVF")
DbsetOrder(2)
cIndex := CriaTrab(nil,.f.)
cCondicao :='VVF_OPEMOV == "0"'
IndRegua("VVF",cIndex,indexkey(),,cCondicao,OemToAnsi(STR0015))  // Selecionando Registros... - Aguarde... Filtrando registros...

dbSelectArea("VVF")
dbSetOrder(2)


mBrowse( 6, 1,22,75,"VVF",,,,,,aCores)

dbSelectArea("VVF")
Set Filter to
RetIndex("VVF")
dbSetOrder(1)
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
±±³Fun‡„o    ³FS_DEVOLVE³ Autor ³  Andre                ³ Data ³ 24/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Devolucao de Veiculos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DEVOLVE(cAlias, nReg, nOpc)

Local bCampo   := { |nCPO| FieldName(nCPO) }
Local oDlg,	oLojaFor, oCodFor,	oSerOri ,  oNfiOri, oNomFor
Local nCntFor := 0
Local lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Private nQtdVei := 0
Private nQtdVen := 0

Private nAcresFin := 0 // Cria Variavel para compatib. com o VEIVM011

M->VV0_CRECON := ""

If !VVF->VVF_SITNFI $ "123"
	Help(" ",1,"DOCINVALID")
	Return (.F.)
Elseif Empty(VVF->VVF_NUMNFI)
	Help(" ",1,"DOCINVALID")
	Return (.F.)
Elseif VVF->VVF_OPEMOV $ "26"
	Help(" ",1,"DOCINVALID")
	Return (.F.)
Endif

Inclui := lRecTec := .t.
lJaGrv := lMsHelpAuto := .f.
lMsErroAuto := .f.

cNota   := ""
cSerie  := ""

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV0")
While !Eof().and.(x3_arquivo=="VV0")
	if X3USO(x3_usado).and.cNivel>=x3_nivel
		wVar := "M->"+x3_campo
		Private &wVar:= CriaVar(x3_campo)
	Endif
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VVA")
While !Eof().and.(x3_arquivo=="VVA")
	if X3USO(x3_usado).and.cNivel>=x3_nivel
		wVar := "M->"+x3_campo
		Private &wVar:= CriaVar(x3_campo)
	Endif
	DbSkip()
EndDo

dbSelectArea("SA2")
dbSetOrder(1)
if dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cCodFor := VVF->VVF_CODFOR
	cLojaFor:= VVF->VVF_LOJA
	cNomFor := SA2->A2_NOME
Else
	cCodFor := space(06)
	cLojaFor:= space(02)
	cNomFor := space(20)
Endif

Private cTipFat := " "
Private cTipSai := " "
Private cDesMar := " "
Private cDesMod := " "
Private cDesCor := " "

If !VVF->VVF_SITNFI $ "13" .and. nOpc ==3 // Valida
	Help(" ",1,"NFORIINVOP")
	Return (.f.)
Endif

If !VVF->VVF_OPEMOV $ "04" .and. nOpc == 3  // Normal / Consignacao
	Help(" ",1,"NFORINDEVO")
	Return (.f.)
Endif

if !FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	Help(" ",1,"ARQITEINCO")
Endif

dDatMov := VVF->VVF_DATMOV
M->VV0_DATMOV := dDataBase
M->VV0_CODCLI := VVF->VVF_CODFOR
M->VV0_LOJA   := VVF->VVF_LOJA
//M->VV0_CODCLI := cCodFor
//M->VV0_LOJA   := cLojaFor
/*
FG_Seek("SA1","M->VV0_CODCLI+M->VV0_LOJA",1,.f.)
If lA1_IBGE
FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
cEstCli := VAM->VAM_ESTADO
Else
cEstCli := SA1->A1_EST
EndIf
*/
//FG_Seek("SA1","M->VV0_CODCLI+M->VV0_LOJA",1,.f.)
If lA2_IBGE .and. !Empty(SA2->A2_IBGE)
	cEstCli := Posicione("VAM",1,xFilial("VAM")+SA2->A2_IBGE,"VAM_ESTADO")
Else
	cEstCli := SA2->A2_EST
EndIf
M->VV0_FORPAG := VVF->VVF_FORPAG
M->VV0_CODVEN := " "
M->VV0_VALMOV := VVF->VVF_VALMOV
M->VV0_VBAICM := VVF->VVF_VBAICM
M->VV0_TOTICM := VVF->VVF_TOTICM
M->VV0_ALIICM := VVF->VVF_ALIICM
M->VV0_CODBCO := VVF->VVF_CODBCO
M->VV0_CODAGE := VVF->VVF_CODAGE
M->VV0_OPEMOV := "4" // Devolucao
M->VV0_CODTRA := Space(06)
M->VVA_RESERV := ""

cTipPag := RetCondVei()
nTotEnt := VVF->VVF_VALMOV

nQtdVei  := 0
cTipSai  := "4" // Devolucao
aStruCha := {}

If nOpc == 4 // Cancelamento

	dbSelectArea("VV0")
	DbSetOrder(5)
	DbSeek(xFilial("VV0")+VVF->VVF_TRACPA)
	While VV0->VV0_FILIAL == xFilial("VV0") .and. VV0->VV0_TRADEV == VVF->VVF_TRACPA
		
  	  nQtdVei := nQtdVei + 1

      VVA->(DbSetOrder(1))
      VVA->(DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA))

		if FG_Seek("VV1","VVA->VVA_CHASSI",2,.f.)
			M->VV1_CODMAR  := VV1->VV1_CODMAR
			M->VV1_MODVEI  := VV1->VV1_MODVEI
			M->VV1_CORVEI  := VV1->VV1_CORVEI
			FG_Seek("VE1","M->VV1_CODMAR",1,.f.)
			cDesMar := VE1->VE1_DESMAR
			FG_Seek("VV2","M->VV1_CODMAR+M->VV1_MODVEI",1,.f.)
			cDesMod := VV2->VV2_DESMOD
			FG_Seek("VVC","M->VV1_CODMAR+M->VV1_CORVEI",1,.f.)
			cDesCor := VVC->VVC_DESCRI
			aadd(aStruCha,{.t.,VVA->VVA_CHASSI,cDesMar,cDesMod,cDesCor,0,VVA->VVA_VCAVEI,VVA->VVA_CHAINT,VV0->VV0_TRADEV,nQtdVei,VV0->VV0_NUMTRA})
		Endif
		
		VV0->(dbSkip())
		
	Enddo

Elseif nOpc <> 2

	dbSelectArea("VVG")
	While VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
		
		nQtdVei := nQtdVei + 1
		
		if !FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
			Help(" ",1,"VEINFNEXCD")
			nOpca := 0
			Return (.f.)
		Endif
		
		if !(VV1->VV1_SITVEI $ "034") .and. nOpc == 3
			SF4->(DbSeek(xFilial("SF4")+VVG->VVG_CODTES))
			If SF4->F4_ESTOQUE == "S"
			   If VV1->VV1_SITVEI <> " "
				 nQtdVen++
			   Endif
	//			Help(" ",1,"VEICSNESTQ")
	//			nOpca := 0
	//			Return .f.
				DbSkip()
				Loop
			Endif
		Endif
		
		M->VV1_CODMAR  := VV1->VV1_CODMAR
		M->VV1_MODVEI  := VV1->VV1_MODVEI
		M->VV1_CORVEI  := VV1->VV1_CORVEI
		FG_Seek("VE1","M->VV1_CODMAR",1,.f.)
		cDesMar := VE1->VE1_DESMAR
		FG_Seek("VV2","M->VV1_CODMAR+M->VV1_MODVEI",1,.f.)
		cDesMod := VV2->VV2_DESMOD
		FG_Seek("VVC","M->VV1_CODMAR+M->VV1_CORVEI",1,.f.)
		cDesCor := VVC->VVC_DESCRI
		aadd(aStruCha,{.t.,VVG->VVG_CHASSI,cDesMar,cDesMod,cDesCor,VVG->VVG_ICMCOM,VVG->VVG_VCNVEI,VVG->VVG_CHAINT,VVG->VVG_TRACPA,nQtdVei,""})
		
		VVG->(dbSkip())
		
	Enddo
	
Elseif nOpc == 2

	dbSelectArea("VVG")
	While VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
		
		
		M->VV1_CODMAR  := VV1->VV1_CODMAR
		M->VV1_MODVEI  := VV1->VV1_MODVEI
		M->VV1_CORVEI  := VV1->VV1_CORVEI
		FG_Seek("VE1","M->VV1_CODMAR",1,.f.)
		cDesMar := VE1->VE1_DESMAR
		FG_Seek("VV2","M->VV1_CODMAR+M->VV1_MODVEI",1,.f.)
		cDesMod := VV2->VV2_DESMOD
		FG_Seek("VVC","M->VV1_CODMAR+M->VV1_CORVEI",1,.f.)
		cDesCor := VVC->VVC_DESCRI
		aadd(aStruCha,{.t.,VVG->VVG_CHASSI,cDesMar,cDesMod,cDesCor,VVG->VVG_ICMCOM,VVG->VVG_VCNVEI,VVG->VVG_CHAINT,VVG->VVG_TRACPA,nQtdVei,""})
		
		VVG->(dbSkip())
		
	Enddo
	
Endif
If Len(aStruCha) == 0
    aadd(aStruCha,{.f.,"","","","",0,0,"","",0,""})
Endif
aEncVVF  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VVF")
While !Eof().and.(x3_arquivo=="VVF")
	if X3USO(x3_usado).and.cNivel>=x3_nivel .and. alltrim(x3_Campo) $ "VVF_DATMOV#VVF_NUMNFI#VVF_SERNFI#VVF_CODFOR#VVF_LOJA#VVF_NOMFOR#VVF_TOTICM#VVF_VALMOV"
		AADD(aEncVVF,x3_campo)
	Endif
	DbSkip()
EndDo

DbSelectArea("VVF")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

FG_Seek("SA2","M->VVF_CODFOR+M->VVF_LOJA",1,.f.)
M->VVF_NOMFOR := SA2->A2_NREDUZ

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0097) FROM  01,10 TO 20,90 OF oMainWnd

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0), nPosAnt:=9999, nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE    := 2
nOpcG    := 2
lVirtual := .f.
nLinhas  := 99

aTela := {}
aGets := {}
dbSelectArea("VVF")
Zero()
oEnc02:= MsMGet():New("VVF" ,0 ,2,,,,aEncVVF,{12,1,75,315},,,,,,oDlg,,.T.,.F.,)

@ 78,1 LISTBOX oLbox FIELDS HEADER;
OemToAnsi(""),; // Indicador de Relacionamento
OemToAnsi(STR0088),;
OemtoAnsi(STR0063),;
OemToAnsi(STR0064),;
OemtoAnsi(STR0065),;
OemToAnsi(STR0086),;
OemToAnsi(STR0099);
COLSIZES 5,80,40,50,50,40,40;
SIZE 315,67 OF oDlg PIXEL ON DBLCLICK (nPos:=oLbox:nAt,FS_MarcCha(),oLbox:Refresh(),oLbox:nAt:=nPos)

oLbox:SetArray(aStruCha)
oLbox:bLine := { || { if(aStruCha[oLbox:nAt,01] == .f.,oNo,oTik),;
aStruCha[oLbox:nAt,02],;
aStruCha[oLbox:nAt,03],;
aStruCha[oLbox:nAt,04],;
aStruCha[oLbox:nAt,05],;
FG_AlinVlrs(Transform(aStruCha[oLbox:nAt,06],"9,999,999.99")),;
FG_AlinVlrs(Transform(aStruCha[oLbox:nAt,07],"9,999,999.99")) } }

//ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| Processa({||nOpca1 := 1,if(FS_DevCpa(cAlias, nReg, nOpca1,nOpc),oDlg:End(),.t.)},"",.t.)},{||nOpca1 := 2,oDlg:End()})
ACTIVATE MSDIALOG oDlg CENTER ON INIT(EnchoiceBar(oDlg,{|| nOpca1:=1,if(FS_DevCpa(cAlias, nReg, nOpca1,nOpc),oDlg:End(),.t.)} , {|| nOpca1 := 0,oDlg:End() }))

Return


///////////////////////////////////////////////
Function FS_DevCpa(cAlias, nReg, nOpca1, nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local oFormul, cForPro := "", lSerie := .F.
Local nCntFor,i := 0
Local cNumero
Local cChassi := ""

Private cVM018CD,cVM018LD,cVM018CT,cVM018FR,cVM018TR,cVM018TF
Private oFnt3, oFnt4, oFnt7
Private cPrefNF := ""
Private cPrefix := GETMV("MV_PREFVEI",,"VEI") //Veiculos
Private cParPrg := "3"
Private i_x
Private cMsg := ""

DEFINE FONT oFnt4 NAME "Arial" BOLD
DEFINE FONT oFnt3 NAME "Arial" SIZE 08,13 BOLD
DEFINE FONT oFnt7 NAME "Times New Roman" SIZE 07,13 BOLD

If nOpc == 2
	Return .T.
Endif         

lMsErroAuto := .f.

lSel := .f.
For i = 1 to len(aStruCha)
	if aStruCha[i,1]
		lSel := .t.
	Endif
Next             
If !lSel 
	MsgStop("Não foram selecionados veículos para a Operação desejada! Favor selecionar!")
	Return .f.
Endif


if nOpca1 == 1
	
	dDatEmi := dDataBase
	cVM018CT := Space(3)
	cVM018CD := M->VVF_CODFOR
	cVM018LD := M->VVF_LOJA
	cNomDes := ""
	cDesTes := ""
	cDesDes := ""
	FS_VALFOR(1)
	FS_VALFOR(2)
	nOpca   := 2
	cCodBco := ""
	cTipPag := ""
	cVM018TR	:= Space(TamSX3("VV0_CODTRA")[1])
	cVM018FR := 0
	cVM018TF := Space(TamSX3("VV0_TPFRET")[1])
	cNomTrans := ""
	
	if nOpc == 3

	
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0294) FROM  02,06 TO 20,65 OF oMainWnd  //Dados da Devolucao
		
		@ 017,014 SAY OemToAnsi(STR0047) OF oDlg PIXEL COLOR CLR_BLUE              // TES
		@ 017,064 MSGET oCodTes VAR cVM018CT PICTURE "@!" VALID FS_VALTES2(cVM018CT) F3 "SF4" SIZE 43,4 OF oDlg PIXEL COLOR CLR_BLACK
		@ 030,014 SAY oDesTes VAR cDesTes SIZE 160,8 OF oDlg PIXEL COLOR CLR_BLUE   // Descricao do TES
		@ 043,014 SAY OemToAnsi(STR0050) OF oDlg PIXEL COLOR CLR_BLUE //Fornecedor
		@ 043,064 MSGET oCodDes VAR cVM018CD PICTURE "@!" VALID (ExistCPO("SA2"),FS_VALFOR018()) F3 "FOR" OF oDlg PIXEL COLOR CLR_BLACK
		@ 056,014 SAY OemToAnsi(STR0094) OF oDlg PIXEL COLOR CLR_BLUE //Loja
		@ 056,064 MSGET oCodLoj VAR cVM018LD PICTURE "@!" VALID (ExistCPO("SA2",cVM018CD+cVM018LD),FS_VALFOR018(),cDesDes := SA2->A2_NOME,.T.) OF oDlg PIXEL COLOR CLR_BLACK
		@ 069,014 SAY oNomDes VAR cDesDes SIZE 160,8 OF oDlg PIXEL COLOR CLR_BLUE   // Descricao do TES
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 31/07/2009                                              ³
		//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
		//³FNC 18018/2009                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 082,014 SAY RetTitle("VV0_CODTRA") OF oDlg PIXEL COLOR CLR_BLUE  // Transportadora
		@ 082,064 MSGET oCodTra VAR cVM018TR VALID ( cNomTrans := Posicione("SA4",1,xFilial("SA4") + cVM018TR , "A4_NOME") , IIF(Empty(cVM018TR), .t. , IIF(ExistCPO("SA4",cVM018TR), .t. , (cVM018TR := Space(Len(cVM018TR)),.f.)) ) ) PICTURE PesqPict("VVA","VV0_CODTRA") F3 "SA4" OF oDlg PIXEL COLOR CLR_BLACK
		@ 095,014 SAY oNomTrans VAR cNomTrans SIZE 160,8 OF oDlg PIXEL COLOR CLR_BLUE   // Descricao do TES
		
		@ 108,014 SAY RetTitle("VVA_VALFRE") OF oDlg PIXEL COLOR CLR_BLUE  // Valor do Frete
		@ 108,064 MSGET oValFre VAR cVM018FR PICTURE PesqPict("VVA","VVA_VALFRE") SIZE 50,4  OF oDlg PIXEL COLOR CLR_BLACK
		
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("VV0_TPFRET"))
		aTPFRETE := FormatIN(" ;" + AllTrim(X3CBOX()),";")
		aTPFRETE := StrTran(aTPFRETE,"(","{")
		aTPFRETE := StrTran(aTPFRETE,")","}")
		aTPFRETE := &(aTPFRETE)
		@ 121,014 SAY RetTitle("VV0_TPFRET") OF oDlg Pixel COLOR CLR_BLUE
		@ 121,064 MSCOMBOBOX oTPFRETE VAR cVM018TF SIZE 30,19 ITEMS aTPFRETE OF oDlg PIXEL COLOR CLR_BLACK
		
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 2,oDlg:End()})
		
		if nOpca <> 1
			Return .t.
		Endif
		
		if Empty(cVM018CT)
			MsgInfo(STR0295,STR0199)//E necessario informar o Tipo de Entrada (TES)... - Atencao!
			Return .f.
		Endif
	Endif
	
Endif

cNumero := VVF->VVF_TRACPA

if nOpc == 4
	
	cDesTpV := STR0297 //CANCELAMENTO DE DEVOLUCAO

	nQtdaCan:=0
	For i = 1 to Len(aStruCha)
   		If aStruCha[i,1]
   		   nQtdaCan++
   		Endif
    Next
	For i = 1 to Len(aStruCha)
		
   		If aStruCha[i,1]
   		
			VV0->(DbSetOrder(1))
			VV0->(Dbseek(xFilial("VV0")+aStruCha[i,11]))
			SD2->(DbsetOrder(3))
			if SD2->(DbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
					
				DbSelectArea("VV0")
				For nCntFor := 1 TO FCount()
					M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
				Next
					
				DbSelectArea("VVA")
				DbSetOrder(1)
				if DbSeek(xFilial("VVA")+aStruCha[i,11])
					cChassi += VVA->VVA_CHASSI+"."
					DbSelectArea("VVA")
					For nCntFor := 1 TO FCount()
						M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
					Next
				Endif
						
				// Ponto de Entrada Antes do Cancelamento
				If ExistBlock("VM018ACA")
					ExecBlock("VM018ACA",.f.,.f.)
				EndIf
							
				DbSelectArea("VV0")
				DbSetOrder(1)
						
				FS_CANCSAI(cAlias, nReg, nOpc)
							
				If nQtdaCan == nQtdVei 
					cSitNF := "1" // Normal
				Else
					cSitNF := "3" // Devol. Parcial
				Endif
					
				FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
				dbSelectArea("SB1")
				dbSetOrder(7)
				dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
				dbSetOrder(1)
				
				FM_LOCVZL(1)
				DbSelectArea("VVF")
				DbSetOrder(1)
				if DbSeek(xFilial("VVF")+cNumero)
					RecLock("VVF",.f.)
					VVF->VVF_SITNFI := cSitNF //"1" // Normal
					MsUnlock()
				Endif
					
				FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
			
				// Ponto de Entrada Depois do Cancelamento
				If ExistBlock("VM018DCA")
					ExecBlock("VM018DCA",.f.,.f.)
				EndIf
				
			Else
				MsgInfo(STR0296 ,STR0199) //Esta Nota nao foi devolvida... - Atencao!
			Endif
		Endif	
		
	Next
Else
	
	If FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
		Return .f.
	Endif
	
	Private lMsHelpAuto := .T.	 , lMsFinalAuto := .F.
	Begin Transaction
	If nOpca1 == 1 .and. nOpc == 3
		
		// Ponto de Entrada Antes da Gravacao
		If ExistBlock("VM018AGR")
			ExecBlock("VM018AGR",.f.,.f.)
		EndIf
		
		cSitNF := "2" // devolucao total - aqui
		For i = 1 to len(aStruCha)
			if !aStruCha[i,1]			
				cSitNF := "3" // Devol. Parcial
			Endif
		Next                 
		
		If nQtdVen > 0
		   cSitNF := "3" // Devol. Parcial
		Endif
		   
		For i = 1 to len(aStruCha)
			if aStruCha[i,1]
//				i_x := i
//				FG_Seek("VVG","aStruCha[i_x,8]+aStruCha[i_x,9]",2,.f.)
				VVG->(DbSetOrder(2))
				VVG->(DbSeek(xFilial("VVG")+aStruCha[i,8]+aStruCha[i,9]))
				VV1->(DbSetOrder(2))
				//FG_Seek("VV1","aStruCha[i_x,9]",7,.f.)
				If VV1->(DbSeek(xFilial("VV1")+aStruCha[i,2]))
					dbSelectArea("VV1")
					Reclock("VV1",.f.)
						VV1->VV1_FILENT := VVF->VVF_FILIAL
						VV1->VV1_TRACPA := VVF->VVF_TRACPA
					Msunlock()
				EndIf			
				DbSelectArea("VV0")
				M->VV0_NUMTRA := GetSxeNum("VV0","VV0_NUMTRA")
				ConfirmSx8()
				M->VV0_CHAINT := VVG->VVG_CHAINT
				M->VV0_CHASSI := VVG->VVG_CHASSI
				M->VV0_CODCLI := cVM018CD
				M->VV0_LOJA   := cVM018LD
				M->VV0_CODTES := cVM018CT
				M->VVA_VALMOV := VVG->VVG_VALUNI
				M->VVA_VALVEI := VVG->VVG_VALUNI
				M->VV0_VALMOV := VVG->VVG_VALUNI
				M->VV0_VALTOT := VVG->VVG_VALUNI
				nTotEnt := M->VV0_VALMOV
				M->VV0_VBAICM := VVG->VVG_VBAICM
				M->VV0_TOTICM := VVG->VVG_ICMCOM
				M->VV0_ALIICM := VVG->VVG_ALIICM
				M->VVA_VBAICM := VVG->VVG_VBAICM
				M->VVA_ICMVEN := VVG->VVG_ICMCOM
				M->VVA_ALIICM := VVG->VVG_ALIICM
				M->VVA_CHASSI := VVG->VVG_CHASSI
				M->VVA_CHAINT := VVG->VVG_CHAINT
				M->VVA_REDCUS := VVG->VVG_REDCUS
				M->VVA_VCAVEI := VVG->VVG_VCNVEI
				M->VVA_CODIND := VVG->VVG_CODIND
				M->VVA_VALVDA := VVG->VVG_VALUNI - VVG->VVG_VALDES
				M->VVA_CODTES := cVM018CT
				M->VVA_EMINVD := "0" && Nao
				M->VVA_INPCRT := "0" && Nao
				M->VVA_INISRT := "0" && Nao
				M->VV1_CODMAR  := VV1->VV1_CODMAR
				M->VV1_MODVEI  := VV1->VV1_MODVEI
				M->VV1_CORVEI  := VV1->VV1_CORVEI
				
				cDesMar := Posicione("VE1",1,xFilial("VE1")+M->VV1_CODMAR,"VE1_DESMAR")
				cDesMod := Posicione("VV2",1,xFilial("VV2")+M->VV1_CODMAR+M->VV1_MODVEI,"VV2_DESMOD")
				cDesCor := Posicione("VVC",1,xFilial("VVC")+M->VV1_CODMAR+M->VV1_CORVEI,"VVC_DESCRI")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rubens - 31/07/2009                                              ³
				//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
				//³FNC 18018/2009                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->VV0_CODTRA := cVM018TR
				M->VVA_VALFRE := cVM018FR
				M->VV0_TPFRET := cVM018TF
				
				lJaGrv    := .f.
				Inclui    := .t.
				lRetRec   := .t.
				cIteNFOri := StrZero(aStruCha[i,10],2)//"01"
				cSerOri   := VVF->VVF_SERNFI
				cNfiOri   := VVF->VVF_NUMNFI
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rubens - 31/07/2009                                                                ³
				//³Recalcula valores para considerar o valor do frete digitado nas informacoes fiscais³
				//³FNC 18018/2009                                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FS_CALC011()
//				M->VVA_VBAICM := MaFisRet(1,"IT_BASEICM")
//				M->VVA_ALIICM := MaFisRet(1,"IT_ALIQICM")
//				M->VVA_ICMVEN := MaFisRet(1,"IT_VALICM")
				
				FS_GRAVA010("S",3)
				FS_GRAVA010("G",3)

				dbSelectArea("SB1")
				dbSetOrder(7)
				dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
			
				FM_LOCVZL(2)
				
//				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//				³ Desposicionar, para considerar em SELECT no meio da transacao ³
//				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				VV0->(dbGoTo(VV0->(Recno())))
				VVA->(dbGoTo(VVA->(Recno())))
				
				FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)

				dbSelectArea("VV0")
				reclock("VV0",.f.)
				VV0_VALTOT := SF2->F2_VALBRUT
				VV0_VBAICM := SF2->F2_BASEICM
				VV0_TOTICM := SF2->F2_VALICM
				msunlock()
			Else
			   lParcial := .t.
			Endif
		Next

		DbSelectArea("VVF")
		DbSetOrder(1)
		if DbSeek(xFilial("VVF")+cNumero)
			RecLock("VVF",.f.)
			VVF->VVF_SITNFI := cSitNF 
			MsUnlock()
		Endif
		
		// Ponto de Entrada Depois da Gravacao
		If ExistBlock("VM018DGR")
			ExecBlock("VM018DGR",.f.,.f.)
		EndIf
		
	Endif
	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX6")
	MsRUnLock()

	lMsHelpAuto := .f.

Endif

if lMsErroAuto
	if !Empty(cMsg)
		MsgInfo(cMsg)
	Endif
	MostraErro()
	lMsHelpAuto := .F.
	Return .f.
Endif
lMsHelpAuto := .F.
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_MarcCha     ³ Autor ³  Manoel          ³ Data   26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca no ListBox do Filtro, o Veiculo escolhido e carrega  ³±±
±±³          ³ variaveis necessarias                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MarcCha()

Local bCampo1   := { |nCPO| FieldName(nCPO) }

If aStruCha[oLbox:nAt,1] == .f.
	aStruCha[oLbox:nAt,1] := .t.
Else
	aStruCha[oLbox:nAt,1] := .f.
Endif

oLbox:SetArray(aStruCha)
oLbox:bLine := { || { if(aStruCha[oLbox:nAt,01] == .f.,oNo,oTik),;
aStruCha[oLbox:nAt,02],;
aStruCha[oLbox:nAt,03],;
aStruCha[oLbox:nAt,04],;
aStruCha[oLbox:nAt,05],;
Fg_AlinVlrs(Transform(aStruCha[oLbox:nAt,06],"@E 9,999,999.99")),;
Fg_AlinVlrs(Transform(aStruCha[oLbox:nAt,07],"@E 9,999,999.99")) } }

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALTES ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do TES digitado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALTES2(cTes)

Local lRet := .t.

if Val(cTes) < 500
	lRet := .f.
Endif

if SF4->(DbSeek(xFilial("SF4")+cTes))
	if lRet
		cDesTes := SF4->F4_TEXTO
		oDesTes:Refresh()
	Else
		MsgInfo(OemtoAnsi(STR0298),OemtoAnsi(STR0199)) //O TES Informado se refere a uma ENTRADA, informe um TES correto de SAIDA - Atencao!
	Endif
Else
	lRet := .f.
Endif

if SF4->F4_ESTOQUE == "N"
	MsgInfo(STR0299,STR0199) //Atencao o TES informado nao movimenta estoque... - Atencao!
Endif

Return (lRet)


//////////////////////////////
Static Function FS_VALFOR(nOp)

Local lRet := .t.

dbSelectArea("SA2")
dbSetOrder(1)
if nOp == 1
	if dbSeek(xFilial("SA2")+VVF->VVF_CODFOR)
		cNomDes := SA2->A2_NOME
		//		oNomDes:Refresh()
	Else
		MsgInfo(STR0300,STR0199) //Destinatario nao Cadastrado... - Atencao!
		lRet := .f.
	Endif
Else
	if dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		cNomDes := SA2->A2_NOME
		//		oNomDes:Refresh()
	Else
		MsgInfo(STR0300,STR0199) //Destinatario nao Cadastrado... - Atencao!
		lRet := .f.
	Endif
Endif

Return(lRet)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VM018LEG   ³ Autor ³ Ricardo Farinelli    ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³VEIVM005                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM018LEG()
Local aLegenda :=   		{	{'BR_VERMELHO',STR0301},;	//Outros Tipos de Documento
{'BR_AZUL',STR0302},;	//Disponivel para Devolucao
{'BR_BRANCO',STR0408},;	//"Devolvida Parcialmente"
{'BR_AMARELO',STR0303}}	//Ja Devolvida

BrwLegenda(OemtoAnsi(STR0097),STR0304 ,aLegenda) 	//Legenda

Return .T.

Static Function MenuDef()
Local aRotina := {{STR0009 , "axPesqui"  ,0,1},;   	//Pesquisar
{STR0305, "FS_DEVOLVE",0,2},;  	//Visualizar
{STR0306, "FS_DEVOLVE",0,4},;  	//Devolver
{STR0012, "FS_DEVOLVE",0,4},;  	//Cancelar
{ OemToAnsi(STR0304),"VM018LEG" , 0 , 2,0,.f.},;	//Legenda
{ STR0308  ,"VM018_LVEI" , 0 , 2}}     			//Pesquisa Chassi
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM018_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 26/11/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM018_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,"",""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private oAzul := LoadBitmap( GetResources() , "BR_AZUL" )
Private oVerm := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private oAmar := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oBran := LoadBitmap( GetResources() , "BR_BRANCO" )
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
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0309) FROM  01,05 TO 17,70 OF oMainWnd  //Pesquisa Chassi
@ 003,004 SAY STR0310 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE  //Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0311) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0312),;//Filial
OemToAnsi(STR0313),;//Dt.Movimento
OemToAnsi(STR0314),;//NF/Serie
OemToAnsi(STR0155),;//Valor
OemToAnsi(STR0050);//Fornecedor
COLSIZES 10,35,35,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,08]=="Verm",oVerm,IIf(aLevPesq[oLbLevPesq:nAt,08]=="Azul",oAzul,IIf(aLevPesq[oLbLevPesq:nAt,08]=="Amar",oAmar,oBran))),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VVF")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	dbSetOrder(1)//TRACPA
	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif
Return

Static Function FS_LEVVEI()
Local cEmpAtu 	:= ""
Local nEmpAtu 	:= 0
Local lOk 		:= .t.
Local cQuery 	:= ""
Local cQAlVVF 	:= "SQLVVF"
Local cFilLibs := ""
Local cCor 		:=""
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VVF.VVF_TRACPA , VVF.VVF_SITNFI , VVF.VVF_FILIAL , VVF.VVF_OPEMOV , VVF.VVF_DATMOV , VVF.VVF_NUMNFI , VVF.VVF_SERNFI , VVF.VVF_VALMOV , VVF.VVF_CODFOR , VVF.VVF_LOJA FROM "+RetSqlName("VVF")+" VVF , "+RetSqlName("VVG")+" VVG WHERE "
	cQuery += "VVG.VVG_CHASSI='"+cLevChas+"' AND VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VVF.VVF_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VVF.VVF_OPEMOV='0' AND VVF.D_E_L_E_T_=' ' AND VVG.D_E_L_E_T_=' ' ORDER BY VVF.VVF_DATMOV "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
	Do While !( cQAlVVF )->( Eof() )
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + ( cQAlVVF )->( VVF_CODFOR ) + ( cQAlVVF )->( VVF_LOJA ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVVF )->( VVF_FILIAL ) })
		If nEmpAtu > 0
			cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
		EndIf
		cCor := ""
		If !(( cQAlVVF )->( VVF_SITNFI ) $ "123") .OR. Empty(( cQAlVVF )->( VVF_NUMNFI )) .or. ( cQAlVVF )->( VVF_OPEMOV ) $ "26"
			cCor := "Verm"
		ElseIf ( cQAlVVF )->( VVF_SITNFI ) $ "13" .and. !Empty(( cQAlVVF )->( VVF_NUMNFI )) .and. !(( cQAlVVF )->( VVF_OPEMOV ) $ "26")
			cCor := "Azul"
		ElseIf ( cQAlVVF )->( VVF_SITNFI ) $ "23" .and. !Empty(( cQAlVVF )->( VVF_NUMNFI )) .and. !(( cQAlVVF )->( VVF_OPEMOV ) $ "26")
			cCor := "Amar"
		EndIf
		
		aAdd(aLevPesq,{ ( cQAlVVF )->( VVF_TRACPA ) , ( cQAlVVF )->( VVF_SITNFI ) , ( cQAlVVF )->( VVF_FILIAL )+"-"+cEmpAtu , stod(( cQAlVVF )->( VVF_DATMOV )) , ( cQAlVVF )->( VVF_NUMNFI )+"-"+( cQAlVVF )->( VVF_SERNFI ) , ( cQAlVVF )->( VVF_VALMOV ) , ( cQAlVVF )->( VVF_CODFOR )+"-"+( cQAlVVF )->( VVF_LOJA )+" "+SA2->A2_NOME , cCor })
		( cQAlVVF )->( DbSkip() )
	EndDo
	( cQAlVVF )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0315+" "+cLevChas,STR0199) //Nenhuma Dev. Entrada encontrada para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,"",""}}
		lOk := .f.
	EndIf
	
	
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,08]=="Verm",oVerm,IIf(aLevPesq[oLbLevPesq:nAt,08]=="Azul",oAzul,IIf(aLevPesq[oLbLevPesq:nAt,08]=="Amar",oAmar,oBran))),;
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
±±³Fun‡„o    ³FS_VALFOR018 ³ Autor ³  Rubens            ³ Data ³ 02/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicializador de Informacoes Fiscais                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALFOR018()

If !MaFisFound('NF')
	If !Empty(cVM018LD)
		MaFisIni(cVM018CD,cVM018LD,'F','N',SA2->A2_TIPO,MaFisRelImp("VEIVM000",{"VVF","VVG"}))
	EndIf
Else
	FS_FisRef("NF_CODCLIFOR",cVM018CD)
	If !Empty(cVM018LD)
		FS_FisRef("NF_LOJA",cVM018LD)
	EndIf
EndIf

Return (.t.)
